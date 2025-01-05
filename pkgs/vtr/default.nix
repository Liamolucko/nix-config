{
  lib,
  stdenv,
  fetchFromGitHub,
  replaceVars,
  bison,
  capnproto-java,
  cmake,
  eigen,
  flex,
  libffi,
  perl,
  pkg-config,
  python3,
  readline,
  tbb_2021_11,
  tcl,
  time,
  zlib,
  enableTbb ? true,
# TODO add withGraphics
# TODO add withPgo (if it's deterministic?)
}:
stdenv.mkDerivation {
  pname = "vtr";
  version = "8.0.0-unstable-2024-12-21";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "0b20db91e040ee04c2b443b4c0a73daee6c48104";
    hash = "sha256-ZKnnIZkM5rpf5SM8IEwL0cALasL+/XCYu8i/joXZxDg=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./no-wget.patch { inherit capnproto-java; })
    (replaceVars ./no-abs-paths.patch { time = lib.getExe time; })
    # TODO upstream
    # bugfixes
    ./allow-stubs.patch
    ./fix-backwards-ifdefs.patch
    ./fix-symlinks.patch
    ./ignore-non-synth.patch
    # mac support
    ./add-missing-includes.patch
    ./avoid-segfault.patch
    ./clear-properly.patch # intermittent
    ./parmys-so.patch
    # running tests in random order? (avoid-segfault also kinda falls in this category, except that it's triggered by macos's default order)
    # or maybe this was just used in the process of debugging our way to clear-properly
    ./fix-uninit.patch
  ];

  nativeBuildInputs = [
    cmake
    bison
    flex
    pkg-config
    python3
    tcl
  ];
  buildInputs = [
    eigen
    libffi
    readline
    tcl
    zlib
  ] ++ lib.optionals enableTbb [ tbb_2021_11 ];

  strictDeps = true;

  cmakeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-DCMAKE_SHARED_LINKER_FLAGS=-undefined dynamic_lookup"
  ];
  __structuredAttrs = true;

  doCheck = true;
  nativeCheckInputs = [
    perl
    python3.pkgs.prettytable
  ];
  checkPhase = ''
    make test

    patchShebangs --build ../vtr_flow/scripts
    python ../run_reg_test.py vtr_reg_basic -skip_qor
  '';

  meta = {
    description = "Open Source CAD Flow for FPGA Research";
    homepage = "https://verilogtorouting.org/";
    # Note that ABC (which is included)'s license isn't MIT (although it's similar);
    # but nixpkgs's ABC calls it the MIT license so it's probably fine?
    license = lib.licenses.mit;
  };
}
