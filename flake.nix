{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-xilinx.url = "gitlab:doronbehar/nix-xilinx";
    nix-xilinx.inputs.nixpkgs.follows = "nixpkgs";
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
      nix-xilinx,
      nix-vscode-extensions,
      mini-compile-commands,
    }:
    let
      overlays = [
        nix-vscode-extensions.overlays.default
        # note: this always builds for x86 regardless of the host system (which is what
        # I want).
        nix-xilinx.overlay
        self.overlays.default
      ];
    in
    {
      overlays.default = final: prev: {
        calyx-lsp = final.callPackage ./pkgs/calyx-lsp { };
        # TODO: fasm has a binary that we should package but there's already something
        # else with that name, what to call it?
        f4pga = with final.python3Packages; toPythonApplication f4pga;
        f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs { };
        fex = final.callPackage ./pkgs/fex.nix { };
        llvm-mctoll = final.callPackage ./pkgs/llvm-mctoll.nix { };
        prjxray-db = final.callPackage ./pkgs/prjxray-db.nix { };
        prjxray-tools = final.callPackage ./pkgs/prjxray-tools { };
        rsyntaxtree = final.callPackage ./pkgs/rsyntaxtree { };
        spade-language-server = final.callPackage ./pkgs/spade-language-server { };
        swim = final.callPackage ./pkgs/swim { };
        tinyfpgab = final.callPackage ./pkgs/tinyfpgab { };
        v2x = final.callPackage ./pkgs/v2x { };
        vivado = final.callPackage ./pkgs/vivado { };
        vtr = final.callPackage ./pkgs/vtr { };
        quicklogic-fasm = final.callPackage ./pkgs/quicklogic-fasm { };
        quicklogic-timings-importer = final.callPackage ./pkgs/quicklogic-timings-importer { };
        qlf-fasm = final.callPackage ./pkgs/qlf-fasm { };
        xc-fasm = with final.python3Packages; toPythonApplication xc-fasm;
        xinstall = final.callPackage ./pkgs/xinstall { };

        capnproto = prev.capnproto.overrideAttrs {
          # Rebase of https://github.com/capnproto/capnproto/pull/1130.
          patches = [ ./capnproto-fix-large-writes.patch ];
        };

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            # We want the application version of xc-fasm, not the package version.
            f4pga = python-final.callPackage ./pkgs/f4pga { xc-fasm = final.xc-fasm; };
            fasm = python-final.callPackage ./pkgs/fasm.nix { };
            fasm-utils = python-final.callPackage ./pkgs/fasm-utils { };
            hilbertcurve_1 = python-final.callPackage ./pkgs/hilbertcurve/1.nix { };
            litedram = python-final.callPackage ./pkgs/litedram { };
            liteeth = python-final.callPackage ./pkgs/liteeth { };
            liteiclink = python-final.callPackage ./pkgs/liteiclink { };
            litepcie = python-final.callPackage ./pkgs/litepcie { };
            litesata = python-final.callPackage ./pkgs/litesata { };
            litescope = python-final.callPackage ./pkgs/litescope { };
            litesdcard = python-final.callPackage ./pkgs/litesdcard { };
            litespi = python-final.callPackage ./pkgs/litespi { };
            litex = python-final.callPackage ./pkgs/litex { };
            litex-boards = python-final.callPackage ./pkgs/litex-boards { };
            prjxray = python-final.callPackage ./pkgs/prjxray.nix { };
            pyjson = python-final.callPackage ./pkgs/pyjson.nix { };
            pythondata-cpu-serv = python-final.callPackage ./pkgs/pythondata/cpu-serv.nix { };
            pythondata-cpu-vexriscv = python-final.callPackage ./pkgs/pythondata/cpu-vexriscv.nix { };
            pythondata-misc-tapcfg = python-final.callPackage ./pkgs/pythondata/misc-tapcfg.nix { };
            pythondata-misc-usb-ohci = python-final.callPackage ./pkgs/pythondata/misc-usb-ohci.nix { };
            pythondata-software-compiler-rt =
              python-final.callPackage ./pkgs/pythondata/software-compiler-rt.nix
                { };
            pythondata-software-picolibc = python-final.callPackage ./pkgs/pythondata/software-picolibc.nix { };
            sdf-timing = python-final.callPackage ./pkgs/sdf-timing.nix { };
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
            home-manager.users.liam.nixpkgs.overlays = overlays;
            nixpkgs.flake.source = nixpkgs.outPath;
          }
          home-manager.darwinModules.home-manager
          ./mac.nix
        ];
      };

      nixosConfigurations."liam-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { home-manager.users.liam.nixpkgs.overlays = overlays; }
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
