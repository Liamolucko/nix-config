{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  bison,
  clang,
  capnproto-java,
  eigen,
  flex,
  libffi,
  pkg-config,
  python3,
  readline,
  tbb_2021_11,
  tcl,
  zlib,
  enableTbb ? true,
# TODO add withGraphics
# TODO add withPgo (if it's deterministic?)
}:
stdenv.mkDerivation {
  pname = "vtr";
  version = "8.0.0-unstable-2024-08-03";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    rev = "49de5fb78364771b440b69dc95622d0db52e01f3";
    hash = "sha256-PemW7B/pjMVPlUFOADLoVJRxXFalPcS+sP08ps/3xZM=";
    fetchSubmodules = true;
  };

  patches = [
    ./no-wget.patch
    ./yosys-fix-clang-build.patch
    # TODO upstream
    ./allow-stubs.patch
    ./fix-backwards-ifdefs.patch
    ./fix-symlinks.patch
    ./ignore-non-synth.patch
    ./add-missing-includes.patch
    ./avoid-segfault.patch
    ./clear-properly.patch
    ./fix-uninit.patch
  ];
  postPatch = ''
    substituteInPlace \
      libs/EXTERNAL/libinterchange/cmake/cxx_static/CMakeLists.txt \
      libs/libvtrcapnproto/CMakeLists.txt \
      --subst-var-by capnprotoJavaSrc '${capnproto-java.src}'
  '';

  nativeBuildInputs = [
    cmake
    bison
    clang # Used to compile yosys
    flex
    libffi
    pkg-config
    python3
    tcl
  ];
  buildInputs = [
    eigen
    readline
    zlib
  ] ++ lib.optionals enableTbb [ tbb_2021_11 ];

  preConfigure = lib.optionalString stdenv.isDarwin ''
    cmakeFlagsArray+=(
      -DCMAKE_SHARED_LINKER_FLAGS="-undefined dynamic_lookup"
    )
  '';

  doCheck = true;

  meta = {
    description = "Open Source CAD Flow for FPGA Research";
    homepage = "https://verilogtorouting.org/";
    # Note that ABC (which is included)'s license isn't MIT (although it's similar);
    # but nixpkgs's ABC calls it the MIT license so it's probably fine?
    license = lib.licenses.mit;
  };
}
