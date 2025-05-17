final: prev: {
  pkgsx86_64Linux = import final.path {
    localSystem = "x86_64-linux";
    inherit (final) config overlays;
  };

  docnav = final.callPackage ./pkgs/docnav { };
  eqy = final.callPackage ./pkgs/eqy { };
  # TODO: fasm has a binary that we should package but there's already something
  # else with that name, what to call it?
  f4pga = with final.python3Packages; toPythonApplication f4pga;
  f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs { };
  libkrun = final.callPackage ./pkgs/libkrun {
    virglrenderer = final.virglrenderer.overrideAttrs (old: {
      src = final.fetchurl {
        url = "https://gitlab.freedesktop.org/asahi/virglrenderer/-/archive/asahi-20250424/virglrenderer-asahi-20250424.tar.bz2";
        hash = "sha256-9qFOsSv8o6h9nJXtMKksEaFlDP1of/LXsg3LCRL79JM=";
      };
      mesonFlags = old.mesonFlags ++ [ (final.lib.mesonOption "drm-renderers" "asahi-experimental") ];
    });
  };
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
  yosys = prev.yosys.overrideAttrs (old: {
    patches = old.patches ++ [
      (final.fetchpatch {
        url = "https://github.com/YosysHQ/yosys/commit/8e508f2a2ade89e5e301de18c922155698ae6960.diff";
        hash = "sha256-UoaHfJ/80cBK/ck5e3EJTe0a95TB5Qz/8Yld/3PX3vA=";
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
    })
  ];
}
