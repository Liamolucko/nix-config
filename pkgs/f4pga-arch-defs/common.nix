# TODO: fix ibex_arty.sdc being a broken symlink
{
  lib,
  pkgsCross,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  fusesoc,
  runCommand,
  symlinkJoin,
  cmake,
  haskellPackages,
  icestorm,
  libxml2,
  ninja,
  nodejs,
  openocd,
  prjxray-db,
  prjxray-tools,
  python3,
  qlf-fasm,
  quicklogic-fasm,
  quicklogic-timings-importer,
  tinyfpgab,
  tinyprog,
  v2x,
  iverilog,
  vtr,
  xc-fasm,
  yapf,
  yosys,
  yosys-symbiflow,
  family,
  device,
}:
let
  lowrisc-edalize = python3.pkgs.edalize.overrideAttrs {
    src = fetchFromGitHub {
      owner = "lowRISC";
      repo = "edalize";
      # latest commit on 'ot' branch as of 2024-06-08
      rev = "5ae2c3e1ca306e27d81ce5fcc769f62cb7ac42d0";
      hash = "sha256-iIf7bUBE2SeS/TByUNL9wI1LswlHTmgHYGJltWXNUWE=";
    };
    # The normal edalize tries to disable tests which don't exist yet.
    disabledTestPaths = [
      "tests/test_apicula.py"
      "tests/test_ascentlint.py"
      "tests/test_diamond.py"
      "tests/test_ghdl.py"
      "tests/test_icarus.py"
      "tests/test_icestorm.py"
      "tests/test_ise.py"
      "tests/test_mistral.py"
      "tests/test_openlane.py"
      "tests/test_oxide.py"
      "tests/test_quartus.py"
      "tests/test_radiant.py"
      "tests/test_spyglass.py"
      "tests/test_symbiyosys.py"
      "tests/test_trellis.py"
      "tests/test_vcs.py"
      "tests/test_veribleformat.py"
      "tests/test_veriblelint.py"
      "tests/test_vivado.py"
      "tests/test_xcelium.py"
      "tests/test_xsim.py"
    ];
  };
  lowrisc-fusesoc = (fusesoc.override { edalize = lowrisc-edalize; }).overridePythonAttrs {
    src = fetchFromGitHub {
      owner = "lowRISC";
      repo = "fusesoc";
      # latest commit on 'ot' branch as of 2024-06-08
      rev = "14dfc825ced58fe1fb343662fa80fc4fbd0fdc50";
      hash = "sha256-Q+Q/X/hgpdzrHke2kXaXAsTp+8p1wRJi2pvtOKwd1/Q=";
    };
    postFixup = ''
      # Don't add Python to PATH, since then it ends up taking priority over the
      # `withPackages` version of it we want to use.
      mv $out/bin/{.fusesoc-wrapped,fusesoc}
      wrapProgram $out/bin/fusesoc $makeWrapperArgs
    '';
  };

  # TODO: it seems like this repo has built artifacts commited to it, maybe
  # rebuild them?
  # (It's a similar story to prjxray-db, except that that requires unfree software
  # (Vivado) to be built and this doesn't.)
  qlfpga-symbiflow-plugins = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "qlfpga-symbiflow-plugins";
    rev = "6a773c76c66e08fa107c6940fa345674c206354e";
    hash = "sha256-8TiBGUfoJ5+FMIzl2SzUHWJSUwV1vp3ipH4xm/GaBwI=";
  };

  # For some godforsaken reason, f4pga-arch-defs expects sv2v to be on PATH with
  # the name zachjs-sv2v instead.
  zachjs-sv2v = runCommand "zachjs-sv2v" { } ''
    mkdir -p $out/bin
    ln -s ${haskellPackages.sv2v}/bin/sv2v $out/bin/zachjs-sv2v
  '';

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "f4pga-arch-defs";
    # From https://f4pga.readthedocs.io/en/latest/development/changes.html#id1
    rev = "66a976d26bd837e34cd6d1b0cf68735703248d06";
    hash = "sha256-xcLhx48g8mf5PZg0e8WlpsPayTuUfee92B14ogseI8Y=";
    fetchSubmodules = true;
    postFetch = ''
      # This folder contains files named both XilPM.pdf and xilpm.pdf, causing
      # problems on Darwin's case-insensitive filesystem and resulting in different
      # hashes between Darwin and Linux.
      #
      # Just get rid of it, we don't need it.
      rm -rf $out/third_party/prjuray/third_party/embeddedsw/lib/sw_services/xilpm/doc
    '';
  };

  # We need to use their vendored version of litex-boards, since it predates
  # `litex_boards.targets.arty` being renamed to
  # `litex_boards.targets.digilent_arty`.
  #
  # And then we have to use the vendored versions of everything else litex-related
  # too to make them compatible.
  litex = python3.pkgs.litex.overridePythonAttrs (old: {
    version = "2020.12-unstable-2021-02-09";
    src = "${src}/third_party/litex";
    patches = [
      # Backport of https://github.com/enjoy-digital/litex/pull/1476.
      #
      # TODO: I also applied the fix to some more CPUs that that PR doesn't; test if
      # those CPUs are just broken right now upstream, and send a PR if so.
      ./litex-riscv-zicsr.patch
      # Backport of https://github.com/enjoy-digital/litex/pull/943.
      ./litex-getfullargspec.patch
      (fetchpatch {
        url = "https://github.com/enjoy-digital/litex/pull/896.patch";
        hash = "sha256-2tFdeMcOWyjlZwnFbEN5De5E1cLk8gqItdqbKp/IF8I=";
      })
    ];
    dependencies = old.dependencies ++ [ python3.pkgs.pythondata-software-compiler-rt ];
    preCheck = ''
      # test_cpu doesn't exist yet in this version.
      rm test/test_ecc.py
    '';
  });

  litedram = python3.pkgs.litedram.overridePythonAttrs {
    version = "2020.12-unstable-2021-02-02";
    src = "${src}/third_party/litedram";
    dependencies = [
      litex
      python3.pkgs.pyyaml
    ];
    # In this old version of litedram, the genesys2 example is so close to running
    # out of ROM that enabling hardening pushes it over the line.
    hardeningDisable = [ "all" ];
  };

  liteiclink = python3.pkgs.liteiclink.overridePythonAttrs {
    version = "2022.04-unstable-2022-06-28";
    src = "${src}/third_party/liteiclink";
    dependencies = [
      litex
      python3.pkgs.pyyaml
    ];
  };
  liteeth = python3.pkgs.liteeth.overridePythonAttrs {
    version = "2022.04-unstable-2022-07-29";
    src = "${src}/third_party/liteeth";
    dependencies = [
      liteiclink
      litex
      python3.pkgs.pyyaml
    ];
    # Dependabot automatically updated liteeth as far as it could without causing it
    # to become incompatible with the vendored version of litex and break the build;
    # however, it did become incompatible enough for liteeth's tests to fail.
    doCheck = false;
  };

  litex-boards = python3.pkgs.litex-boards.overridePythonAttrs {
    version = "2020.12-unstable-2021-02-04";
    src = "${src}/third_party/litex-boards";
    dependencies = [ litex ];
    # I'm not pulling in matching old versions of everything in the LiteX ecosystem
    # just to run these tests.
    doCheck = false;
  };

  # These packages are referenced from scripts that have PYTHONPATH overridden,
  # meaning that they need to be bundled with the interpreter so that they're
  # accessible without being on PYTHONPATH.
  pythonWithPackages = python3.withPackages (p: [
    p.f4pga
    p.fasm
    p.hilbertcurve_1
    litedram
    liteeth
    litex-boards
    p.lxml
    p.mako
    p.numpy
    p.ply
    p.progressbar2
    p.pycapnp
    p.pythondata-cpu-vexriscv
    p.sdf-timing
    p.setuptools
    p.simplejson
    p.termcolor
  ]);

  # TODO: this is getting referenced by the output derivation. Either use
  # `removeReferencesTo` or remove benchmarks from the output entirely.
  yosysWithPlugins = symlinkJoin {
    name = "${yosys.name}-with-plugins";
    paths = [
      yosys
      yosys-symbiflow.design_introspection
      yosys-symbiflow.fasm
      yosys-symbiflow.params
      yosys-symbiflow.ql-iob
      # yosys-symbiflow.ql-qlf # broken
      yosys-symbiflow.sdc
      yosys-symbiflow.xdc
    ];
    # When the yosys binary is a symlink, it runs into an issue on Linux where the
    # xdc plugin ends up looking in the original yosys derivation instead of the
    # joined one for some of its data, and can't find it. So copy it and make sure
    # there's no symlink to be accidentally resolved in the first place.
    #
    # The only reason it can load the plugin itself seems to be because of some
    # Yosys's setup hook; if you bake in the path to Yosys directly rather than
    # using `nativeBuildInputs`, it can't load the plugin either.
    postBuild = ''
      real_yosys=$(realpath $out/bin/yosys)
      rm $out/bin/yosys
      cp $real_yosys $out/bin/yosys
    '';
  };

  # For some reason VPR segfaults on darwin while building this if TBB is enabled.
  vtr' = vtr.override { enableTbb = !(stdenv.isDarwin && family == "xc7"); };
in
stdenv.mkDerivation {
  pname = "f4pga-arch-defs-${device}";
  version = "0-unstable-2022-09-08";
  inherit src;

  patches = [
    ./no-wget.patch
    ./fix-ql-pinmap-install.patch # TODO upstream
    ./use-bins.patch # maybe upstream?
    ./updated-vpr.patch
  ];

  nativeBuildInputs = [
    # Put this first so that it comes before the regular (propagated) python and
    # takes precedence.
    pythonWithPackages
    cmake
    lowrisc-fusesoc
    zachjs-sv2v
    icestorm
    libxml2
    ninja # not _needed_ but nicer (CI uses it)
    nodejs
    openocd
    prjxray-tools
    # The old version of litex we're using doesn't build with GCC 14.
    pkgsCross.riscv64-embedded.buildPackages.gcc13
    python3.pkgs.flake8
    python3.pkgs.pytest
    qlf-fasm
    quicklogic-fasm
    quicklogic-timings-importer
    tinyfpgab
    tinyprog
    v2x
    iverilog
    vtr'
    xc-fasm
    yapf
    yosysWithPlugins
  ];

  # Using PYTHONPATH can cause several problems in the face of multiple Python
  # versions (specifically, v2x's use of Python 3.11):
  #
  # 1. The Python 3.12 version of lxml on PYTHONPATH seems to override v2x's
  # built-in version, and can't be used because it includes native code.
  #
  # 2. v2x's propagated Python 3.11 dependencies can end up taking priority over
  # our Python 3.12 ones, resulting in nothing here working properly. This can be
  # avoided by deleting ${v2x}/nix-support, but then we're back to problem 1
  # again.
  #
  # So, we turn it off and rely wholly on `withPackages` instead.
  dontAddPythonPath = true;

  postPatch = ''
    substituteInPlace quicklogic/common/cmake/quicklogic_env.cmake \
      --subst-var-by qlfpga-symbiflow-plugins ${qlfpga-symbiflow-plugins}
    patchShebangs --build utils/quiet_cmd.sh
  '';
  # fusesoc puts a cache in $HOME, so set it.
  preConfigure = ''
    export HOME=$PWD
    export VPR_NUM_WORKERS=$NIX_BUILD_CORES
  '';
  cmakeFlags = [
    "-DPRJXRAY_DB_DIR=${prjxray-db}"
    "-DYOSYS_DATADIR=${yosysWithPlugins}/share/yosys"
    "-DOPENOCD_DATADIR=${openocd}/share/openocd"
    "-DVPR_CAPNP_SCHEMA_DIR=${vtr'}/share/vtr"
    "-DINSTALL_DEVICES=${device}"
  ];
  prefix = "${placeholder "out"}/${family}";

  meta = {
    description = "FOSS architecture definitions of FPGA hardware useful for doing PnR device generation";
    homepage = "https://github.com/f4pga/f4pga-arch-defs";
    license = lib.licenses.isc;
  };
}
