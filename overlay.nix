final: prev: {
  pkgsx86_64Linux = import "${final.path}/pkgs/top-level" {
    localSystem = "x86_64-linux";
    inherit (final) config overlays;
  };

  cakeml = final.callPackage ./pkgs/cakeml { };
  docnav = final.callPackage ./pkgs/docnav { };
  eqy = final.callPackage ./pkgs/eqy { };
  # TODO: fasm has a binary that we should package but there's already something
  # else with that name, what to call it?
  f4pga = with final.python3Packages; toPythonApplication f4pga;
  f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs { };
  hol = final.callPackage ./pkgs/hol { };
  libkrun = final.callPackage ./pkgs/libkrun {
    virglrenderer = final.virglrenderer.overrideAttrs (old: {
      src = final.fetchurl {
        url = "https://gitlab.freedesktop.org/asahi/virglrenderer/-/archive/asahi-20250424/virglrenderer-asahi-20250424.tar.bz2";
        hash = "sha256-9qFOsSv8o6h9nJXtMKksEaFlDP1of/LXsg3LCRL79JM=";
      };
      mesonFlags = old.mesonFlags ++ [ (final.lib.mesonOption "drm-renderers" "asahi-experimental") ];
    });
  };
  nextpnr-xilinx = final.callPackage ./pkgs/nextpnr-xilinx { };
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
  vivado_2025_1 = final.callPackage ./pkgs/vivado { xinstall = final.xinstall_2025_1; };
  vtr = final.callPackage ./pkgs/vtr { };
  xc-fasm = with final.python3Packages; toPythonApplication xc-fasm;
  xinstall = final.xinstall_2025_1;
  xinstall_2024_1 = final.callPackage ./pkgs/xinstall/2024.1.nix { };
  xinstall_2024_2 = final.callPackage ./pkgs/xinstall/2024.2.nix { };
  xinstall_2025_1 = final.callPackage ./pkgs/xinstall/2025.1.nix { };

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
      mkdir -p $out/${final.vivado.version}/Vivado/data/boards
      cp -r ${repo}/new/board_files $out/${final.vivado.version}/Vivado/data/boards/board_files
    '';

  dafny = prev.dafny.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (final.fetchpatch2 {
        url = "https://github.com/dafny-lang/dafny/commit/6d95522883a21554293bcb5186eaa48a974ea3b6.diff?full_index=1";
        hash = "sha256-6+KZH3MSamCZO86kPow4mRMPp+e8GP+073fmyYix7Do=";
      })
    ];
  });
  # TODO: upstream
  gfan = prev.gfan.overrideAttrs {
    hardeningDisable = [ "libcxxhardeningfast" ];
  };
  # https://github.com/NixOS/nixpkgs/pull/489725
  vesktop = prev.vesktop.overrideAttrs {
    buildPhase = ''
      runHook preBuild

      pnpm build
      pnpm exec electron-builder \
        --dir \
        -c.asarUnpack="**/*.node" \
        -c.electronDist=${if final.stdenv.hostPlatform.isDarwin then "." else "electron-dist"} \
        -c.electronVersion=${final.electron.version} \
        ${final.lib.optionalString final.stdenv.hostPlatform.isDarwin "-c.mac.identity=null"}

      runHook postBuild
    '';
  };
  yosys = prev.yosys.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./yosys-select-all.patch
      # This is the version which is more in the spirit of the original change, by
      # preserving the distinction between libraries / executables and letting
      # yosys-config be used for executables.
      #
      # I don't really understand why the change was needed, though - the other option
      # would be to just revert it.
      ./yosys-config-exes.patch
    ];
  });
  yosys-symbiflow = final.lib.mapAttrs (
    name: pkg:
    pkg.overrideAttrs {
      patches = [
        ./yosys-symbiflow-include-tcl.patch
        ./yosys-symbiflow-select-boxed.patch
      ];
    }
  ) prev.yosys-symbiflow;

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      dearpygui = python-final.callPackage ./pkgs/dearpygui { };
      # We want the application version of xc-fasm, not the package version.
      f4pga = python-final.callPackage ./pkgs/f4pga { xc-fasm = final.xc-fasm; };
      fasm = python-final.callPackage ./pkgs/fasm { };
      fasm-utils = python-final.callPackage ./pkgs/fasm-utils { };
      hilbertcurve_1 = python-final.callPackage ./pkgs/hilbertcurve/1.nix { };
      litedram = python-final.callPackage ./pkgs/litedram { };
      liteeth = python-final.callPackage ./pkgs/liteeth { };
      litei2c = python-final.callPackage ./pkgs/litei2c { };
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
      pythondata-cpu-blackparrot = python-final.callPackage ./pkgs/pythondata/cpu-blackparrot.nix { };
      pythondata-cpu-coreblocks = python-final.callPackage ./pkgs/pythondata/cpu-coreblocks.nix { };
      pythondata-cpu-cv32e40p = python-final.callPackage ./pkgs/pythondata/cpu-cv32e40p.nix { };
      pythondata-cpu-cv32e41p = python-final.callPackage ./pkgs/pythondata/cpu-cv32e41p.nix { };
      pythondata-cpu-cva5 = python-final.callPackage ./pkgs/pythondata/cpu-cva5.nix { };
      pythondata-cpu-cva6 = python-final.callPackage ./pkgs/pythondata/cpu-cva6.nix { };
      pythondata-cpu-ibex = python-final.callPackage ./pkgs/pythondata/cpu-ibex.nix { };
      pythondata-cpu-lm32 = python-final.callPackage ./pkgs/pythondata/cpu-lm32.nix { };
      pythondata-cpu-marocchino = python-final.callPackage ./pkgs/pythondata/cpu-marocchino.nix { };
      pythondata-cpu-microwatt = python-final.callPackage ./pkgs/pythondata/cpu-microwatt.nix { };
      pythondata-cpu-minerva = python-final.callPackage ./pkgs/pythondata/cpu-minerva.nix { };
      pythondata-cpu-mor1kx = python-final.callPackage ./pkgs/pythondata/cpu-mor1kx.nix { };
      pythondata-cpu-naxriscv = python-final.callPackage ./pkgs/pythondata/cpu-naxriscv.nix { };
      pythondata-cpu-openc906 = python-final.callPackage ./pkgs/pythondata/cpu-openc906.nix { };
      pythondata-cpu-picorv32 = python-final.callPackage ./pkgs/pythondata/cpu-picorv32.nix { };
      pythondata-cpu-rocket = python-final.callPackage ./pkgs/pythondata/cpu-rocket.nix { };
      pythondata-cpu-sentinel = python-final.callPackage ./pkgs/pythondata/cpu-sentinel.nix { };
      pythondata-cpu-serv = python-final.callPackage ./pkgs/pythondata/cpu-serv.nix { };
      # vexiiriscv is missing a license
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

      # inherit (python-final.callPackage ./pkgs/pythondata { })
      #   pythondata-software-picolibc
      #   pythondata-software-compiler-rt
      #   pythondata-misc-tapcfg
      #   pythondata-cpu-marocchino
      #   ;
    })
  ];
}
