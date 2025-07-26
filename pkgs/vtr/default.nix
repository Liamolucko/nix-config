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
  tbb_2021,
  tcl,
  time,
  zlib,
  enableTbb ? true,
# TODO add withGraphics
# TODO add withPgo (if it's deterministic?)
}:
stdenv.mkDerivation {
  pname = "vtr";
  version = "9.0.0-unstable-2025-01-23";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "6ce9dbe61e43074c0080d6dd4311cc0e6f786466";
    hash = "sha256-NfyaA8jZI7CXZHi832cIlRyOnYYZDsxUJDw6AywvWNA=s";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./no-wget.patch { inherit capnproto-java; })
    (replaceVars ./no-abs-paths.patch { time = lib.getExe time; })
    # TODO upstream
    ./allow-stubs.patch
    ./fix-backwards-ifdefs.patch
    ./fix-symlinks.patch
    ./ignore-non-synth.patch
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
  ]
  ++ lib.optionals enableTbb [ tbb_2021 ];

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
