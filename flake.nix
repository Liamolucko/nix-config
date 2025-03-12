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
    openxc7.url = "github:openXC7/toolchain-nix";
    openxc7.inputs.nixpkgs.follows = "nixpkgs";
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
      openxc7,
      mini-compile-commands,
    }:
    let
      overlays = [
        self.overlays.default
      ];
    in
    {
      overlays.default = final: prev: {
        pkgsx86_64Linux = import nixpkgs {
          localSystem = "x86_64-linux";
          inherit (final) config overlays;
        };

        docnav = final.callPackage ./pkgs/docnav { };
        eqy = final.callPackage ./pkgs/eqy { };
        # TODO: fasm has a binary that we should package but there's already something
        # else with that name, what to call it?
        f4pga = with final.python3Packages; toPythonApplication f4pga;
        f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs { };
        libkrun = final.callPackage ./pkgs/libkrun { };
        muvm = final.callPackage ./pkgs/muvm { };
        prjxray-db = final.callPackage ./pkgs/prjxray-db { };
        prjxray-tools = final.callPackage ./pkgs/prjxray-tools { };
        qlf-fasm = final.callPackage ./pkgs/qlf-fasm { };
        quicklogic-fasm = final.callPackage ./pkgs/quicklogic-fasm { };
        quicklogic-timings-importer = final.callPackage ./pkgs/quicklogic-timings-importer { };
        rsyntaxtree = final.callPackage ./pkgs/rsyntaxtree { };
        tinyfpgab = final.callPackage ./pkgs/tinyfpgab { };
        v2x = final.callPackage ./pkgs/v2x { };
        vivado = final.callPackage ./pkgs/vivado { };
        vivado_2024_1 = final.callPackage ./pkgs/vivado { xinstall = final.xinstall_2024_1; };
        vivado_2024_2 = final.callPackage ./pkgs/vivado { xinstall = final.xinstall_2024_2; };
        vtr = final.callPackage ./pkgs/vtr { };
        xc-fasm = with final.python3Packages; toPythonApplication xc-fasm;
        xinstall = final.xinstall_2024_2;
        xinstall_2024_1 = final.callPackage ./pkgs/xinstall/2024.1.nix { };
        xinstall_2024_2 = final.callPackage ./pkgs/xinstall/2024.2.nix { };

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

        isabelle = prev.isabelle.overrideAttrs (old: {
          patches = [ ./isabelle-fix-copied-permissions.patch ];
          # eprover comes with symlinks to its built artifacts, and so using the nixpkgs
          # version instead of building it causes them to be broken.
          #
          # We could solve this by building directly from the mercurial repository instead
          # of using the release tarballs and avoiding contrib/ entirely, but that's a lot
          # of work for such a minor issue.
          dontCheckForBrokenSymlinks = true;
        });
        virglrenderer = prev.virglrenderer.overrideAttrs (old: {
          src = final.fetchurl {
            url = "https://gitlab.freedesktop.org/asahi/virglrenderer/-/archive/asahi-20241205.2/virglrenderer-asahi-20241205.2.tar.bz2";
            hash = "sha256-mESFaB//RThS5Uts8dCRExfxT5DQ+QQgTDWBoQppU7U=";
          };
          mesonFlags = old.mesonFlags ++ [ (final.lib.mesonOption "drm-renderers" "asahi-experimental") ];
        });
        yosys = prev.yosys.overrideAttrs (old: {
          patches = old.patches ++ [
            (final.fetchpatch {
              url = "https://github.com/YosysHQ/yosys/commit/8e508f2a2ade89e5e301de18c922155698ae6960.diff";
              hash = "sha256-UoaHfJ/80cBK/ck5e3EJTe0a95TB5Qz/8Yld/3PX3vA=";
            })
            (final.fetchpatch {
              url = "https://github.com/YosysHQ/yosys/commit/df3c62a4eda60ec79372aaead1188df02855dbb0.diff";
              hash = "sha256-g2GgRNUTQNfAe3dSONCr6/TetqCklOKloaqjetnudkA=";
            })
          ];
        });
        yosys-symbiflow = final.lib.mapAttrs (
          name: pkg:
          pkg.overrideAttrs {
            patches = [ ./yosys-symbiflow-include-tcl.patch ];
          }
        ) prev.yosys-symbiflow;

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
            okonomiyaki = python-prev.okonomiyaki.overrideAttrs {
              # Remove the no-longer-required darwin workaround.
              preCheck = ''
                substituteInPlace okonomiyaki/runtimes/tests/test_runtime.py \
                  --replace 'runtime_info = PythonRuntime.from_running_python()' 'raise unittest.SkipTest() #'
              '';
            };
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
        openxc7Pkgs = openxc7.packages.${system};
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
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.cc
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.bintools
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
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.cc
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.bintools
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
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.cc
                pkgs.pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.bintools
                pkgs.meson
                openxc7Pkgs.nextpnr-xilinx
                pkgs.ninja
                pkgs.prjxray-tools
                pkgs.python3
                (pkgs.python3.pkgs.litex-boards.overridePythonAttrs (old: {
                  patches = [ ./litex-boards.patch ];
                }))
                pkgs.python3.pkgs.prjxray
                pkgs.python3.pkgs.pythondata-cpu-vexriscv
                pkgs.python3.pkgs.pythondata-software-compiler-rt
                pkgs.python3.pkgs.pythondata-software-picolibc
                pkgs.yosys
              ];
              env.CHIPDB = openxc7Pkgs.nextpnr-xilinx-chipdb.artix7;
              env.PRJXRAY_DB_DIR = pkgs.prjxray-db;
            }
            ''
              python -m litex_boards.targets.digilent_basys3 --output-dir "$out" --toolchain openxc7 --build
            '';
      }
    );
}
