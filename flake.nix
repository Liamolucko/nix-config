{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-apple-silicon.url = "github:flokli/nixos-apple-silicon/mainline-mesa";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    mini-compile-commands = {
      url = "github:danielbarter/mini_compile_commands";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      nixos-apple-silicon,
      nix-vscode-extensions,
      mini-compile-commands,
    }:
    let
      overlays = [
        nix-vscode-extensions.overlays.default
        self.overlays.default
      ];
    in
    {
      overlays.default = import ./overlay.nix;

      darwinConfigurations."Liams-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            nixpkgs.overlays = overlays;
            home-manager.users.liam.nixpkgs.overlays = overlays;
          }
          home-manager.darwinModules.home-manager
          ./mac.nix
        ];
      };

      nixosConfigurations."liam-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.overlays = overlays;
            home-manager.users.liam.nixpkgs.overlays = overlays;
          }
          home-manager.nixosModules.home-manager
          ./desktop.nix
        ];
      };

      nixosConfigurations."vivado-vm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          ./vivado-vm.nix
        ];
      };

      nixosConfigurations."pi4" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          ./pi4.nix
        ];
      };

      nixosConfigurations."liam-asahi" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            nixpkgs.overlays = overlays;
            home-manager.users.liam.nixpkgs.overlays = overlays;
          }
          nixos-apple-silicon.nixosModules.default
          home-manager.nixosModules.home-manager
          ./asahi.nix
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        mcc-env = (pkgs.callPackage mini-compile-commands { }).wrap pkgs.stdenv;
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = pkgs // {
          mccPackages = builtins.mapAttrs (name: value: value.override { stdenv = mcc-env; }) pkgs;
        };

        checks.basys3-vivado =
          pkgs.runCommand "basys3-vivado"
            {
              nativeBuildInputs = [
                pkgs.pkgsCross.riscv64-embedded.buildPackages.gccWithoutTargetLibc
                pkgs.glibcLocales
                pkgs.meson
                pkgs.ninja
                pkgs.python3
                pkgs.python3.pkgs.litex-boards
                pkgs.python3.pkgs.pythondata-cpu-vexriscv
                pkgs.python3.pkgs.pythondata-software-compiler-rt
                pkgs.python3.pkgs.pythondata-software-picolibc
                (pkgs.vivado.override { modules = [ "Artix-7" ]; })
              ];
            }
            ''
              # Vivado needs to be able to write to $HOME.
              export HOME="$PWD"
              python -m litex_boards.targets.digilent_basys3 --output-dir "$out" --build
            '';

        checks.basys3-f4pga =
          pkgs.runCommand "basys3-f4pga"
            {
              nativeBuildInputs = [
                pkgs.pkgsCross.riscv64-embedded.buildPackages.gccWithoutTargetLibc
                pkgs.meson
                pkgs.ninja
                pkgs.python3
                pkgs.python3.pkgs.f4pga
                (pkgs.python3.pkgs.litex-boards.overridePythonAttrs (old: {
                  patches = [ ./litex-boards.patch ];
                }))
                pkgs.python3.pkgs.pythondata-cpu-vexriscv
                pkgs.python3.pkgs.pythondata-software-compiler-rt
                pkgs.python3.pkgs.pythondata-software-picolibc
              ];
              env.F4PGA_INSTALL_DIR = pkgs.f4pga-arch-defs.xc7a50t;
            }
            ''
              python -m litex_boards.targets.digilent_basys3 --output-dir "$out" --toolchain f4pga --build
            '';

        checks.basys3-openxc7 =
          pkgs.runCommand "basys3-openxc7"
            {
              nativeBuildInputs = [
                pkgs.pkgsCross.riscv64-embedded.buildPackages.gccWithoutTargetLibc
                pkgs.meson
                pkgs.nextpnr-xilinx
                pkgs.ninja
                pkgs.prjxray-tools
                pkgs.pypy3
                (pkgs.python3.withPackages (ps: [
                  (ps.litex-boards.overridePythonAttrs (old: {
                    patches = [ ./litex-boards.patch ];
                  }))
                  ps.prjxray
                  ps.pythondata-cpu-vexriscv
                  ps.pythondata-software-compiler-rt
                  ps.pythondata-software-picolibc
                ]))
                pkgs.yosys
              ];
              env.NEXTPNR_XILINX_PYTHON_DIR = "${pkgs.nextpnr-xilinx}/share/nextpnr/python";
              env.PRJXRAY_DB_DIR = "${pkgs.nextpnr-xilinx}/share/nextpnr/external/prjxray-db";
            }
            ''
              export CHIPDB=$(mktemp -d)
              python -m litex_boards.targets.digilent_basys3 --output-dir "$out" --toolchain openxc7 --build
            '';
      }
    );
}
