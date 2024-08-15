{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
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
      overlays.default = final: prev: {
        pkgsx86_64Linux = import nixpkgs {
          localSystem = "x86_64-linux";
          inherit (final) config overlays;
        };

        # TODO: fasm has a binary that we should package but there's already something
        # else with that name, what to call it?
        f4pga = with final.python3Packages; toPythonApplication f4pga;
        f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs { };
        fex = final.callPackage ./pkgs/fex { };
        prjxray-db = final.callPackage ./pkgs/prjxray-db { };
        prjxray-tools = final.callPackage ./pkgs/prjxray-tools { };
        qlf-fasm = final.callPackage ./pkgs/qlf-fasm { };
        quicklogic-fasm = final.callPackage ./pkgs/quicklogic-fasm { };
        quicklogic-timings-importer = final.callPackage ./pkgs/quicklogic-timings-importer { };
        rsyntaxtree = final.callPackage ./pkgs/rsyntaxtree { };
        tinyfpgab = final.callPackage ./pkgs/tinyfpgab { };
        v2x = final.callPackage ./pkgs/v2x { };
        vivado = final.callPackage ./pkgs/vivado { };
        vtr = final.callPackage ./pkgs/vtr { };
        xc-fasm = with final.python3Packages; toPythonApplication xc-fasm;
        xinstall = final.callPackage ./pkgs/xinstall { };

        digilent-board-files =
          let
            repo = final.fetchFromGitHub {
              owner = "Digilent";
              repo = "vivado-boards";
              rev = "8ed4f9981da1d80badb0b1f65e250b2dbf7a564d";
              hash = "sha256-yb0Z4+1at3U7ZnH9Db3siHTBIMV4bHUaTu/y3dq+Y0k=";
            };
          in
          final.runCommand "digilent-board-files" { } ''
            mkdir -p $out/Vivado/${final.vivado.version}/data/boards
            cp -r ${repo}/new/board_files $out/Vivado/${final.vivado.version}/data/boards/board_files
          '';

        capnproto = prev.capnproto.overrideAttrs {
          # Rebase of https://github.com/capnproto/capnproto/pull/1130.
          patches = [ ./capnproto-fix-large-writes.patch ];
        };

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            # We want the application version of xc-fasm, not the package version.
            f4pga = python-final.callPackage ./pkgs/f4pga { xc-fasm = final.xc-fasm; };
            fasm = python-final.callPackage ./pkgs/fasm { };
            fasm-utils = python-final.callPackage ./pkgs/fasm-utils { };
            hilbertcurve_1 = python-final.callPackage ./pkgs/hilbertcurve/1.nix { };
            litedram = python-final.callPackage ./pkgs/litedram { };
            liteeth = python-final.callPackage ./pkgs/liteeth { };
            liteiclink = python-final.callPackage ./pkgs/liteiclink { };
            litejesd204b = python-final.callPackage ./pkgs/litejesd204b { };
            litepcie = python-final.callPackage ./pkgs/litepcie { };
            litesata = python-final.callPackage ./pkgs/litesata { };
            litescope = python-final.callPackage ./pkgs/litescope { };
            litesdcard = python-final.callPackage ./pkgs/litesdcard { };
            litespi = python-final.callPackage ./pkgs/litespi { };
            litex = python-final.callPackage ./pkgs/litex { };
            litex-boards = python-final.callPackage ./pkgs/litex-boards { };
            prjxray = python-final.callPackage ./pkgs/prjxray { };
            pyjson = python-final.callPackage ./pkgs/pyjson { };
            pythondata-cpu-lm32 = python-final.callPackage ./pkgs/pythondata/cpu-lm32.nix { };
            pythondata-cpu-mor1kx = python-final.callPackage ./pkgs/pythondata/cpu-mor1kx.nix { };
            pythondata-cpu-marocchino = python-final.callPackage ./pkgs/pythondata/cpu-marocchino.nix { };
            pythondata-cpu-microwatt = python-final.callPackage ./pkgs/pythondata/cpu-microwatt.nix { };
            pythondata-cpu-blackparrot = python-final.callPackage ./pkgs/pythondata/cpu-blackparrot.nix { };
            pythondata-cpu-cv32e40p = python-final.callPackage ./pkgs/pythondata/cpu-cv32e40p.nix { };
            pythondata-cpu-cv32e41p = python-final.callPackage ./pkgs/pythondata/cpu-cv32e41p.nix { };
            pythondata-cpu-cva5 = python-final.callPackage ./pkgs/pythondata/cpu-cva5.nix { };
            pythondata-cpu-cva6 = python-final.callPackage ./pkgs/pythondata/cpu-cva6.nix { };
            pythondata-cpu-ibex = python-final.callPackage ./pkgs/pythondata/cpu-ibex.nix { };
            pythondata-cpu-minerva = python-final.callPackage ./pkgs/pythondata/cpu-minerva.nix { };
            pythondata-cpu-naxriscv = python-final.callPackage ./pkgs/pythondata/cpu-naxriscv.nix { };
            pythondata-cpu-picorv32 = python-final.callPackage ./pkgs/pythondata/cpu-picorv32.nix { };
            pythondata-cpu-rocket = python-final.callPackage ./pkgs/pythondata/cpu-rocket.nix { };
            pythondata-cpu-serv = python-final.callPackage ./pkgs/pythondata/cpu-serv.nix { };
            pythondata-cpu-vexriscv = python-final.callPackage ./pkgs/pythondata/cpu-vexriscv.nix { };
            pythondata-cpu-vexriscv-smp = python-final.callPackage ./pkgs/pythondata/cpu-vexriscv-smp.nix { };
            pythondata-misc-tapcfg = python-final.callPackage ./pkgs/pythondata/misc-tapcfg.nix { };
            pythondata-misc-usb-ohci = python-final.callPackage ./pkgs/pythondata/misc-usb-ohci.nix { };
            pythondata-software-compiler-rt =
              python-final.callPackage ./pkgs/pythondata/software-compiler-rt.nix
                { };
            pythondata-software-picolibc = python-final.callPackage ./pkgs/pythondata/software-picolibc.nix { };
            sdf-timing = python-final.callPackage ./pkgs/sdf-timing { };
            valentyusb = python-final.callPackage ./pkgs/valentyusb { };
            vtr-xml-utils = python-final.callPackage ./pkgs/vtr-xml-utils { };
            xc-fasm = python-final.callPackage ./pkgs/xc-fasm { };

            pycapnp = python-prev.pycapnp.overridePythonAttrs (old: rec {
              version = "2.0.0";
              src = final.fetchFromGitHub {
                owner = "capnproto";
                repo = "pycapnp";
                rev = "v${version}";
                hash = "sha256-SVeBRJMMR1Z8+S+QoiUKGRFGUPS/MlmWLi1qRcGcPoE=";
              };
              nativeBuildInputs = [
                python-final.cython_0
                python-final.pkgconfig
              ];
              buildInputs = [ ];
              # Trick pycapnp into thinking it built capnproto itself, so that it will bundle
              # its `.capnp` files (instead of assuming they'll be in /usr/include).
              postPatch = ''
                ln -s ${final.capnproto} build64
              '';
              meta = old.meta // {
                broken = false;
              };
            });
          })
        ];
      };

      darwinConfigurations."Liams-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          "${nixpkgs}/nixos/modules/misc/nixpkgs-flake.nix"
          {
            nixpkgs.overlays = overlays;
            home-manager.users.liam.nixpkgs.overlays = overlays;
            nixpkgs.flake.source = nixpkgs.outPath;
            # Seems like nix-darwin's default has higher precedence, so we have to do it
            # manually.
            nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
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
      }
    );
}
