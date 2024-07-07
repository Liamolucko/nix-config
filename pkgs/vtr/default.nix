{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  bison,
  capnproto-java,
  eigen,
  flex,
  pkg-config,
  tbb_2021_11,
  zlib,
  enableTbb ? true,
# TODO add withGraphics
# TODO add withPgo (if it's deterministic?)
}:
let
  rev = "a7fae8fb2";
in
stdenv.mkDerivation {
  pname = "vtr";
  # This isn't some weird pre-release version, the commit hash is actually part of
  # the version number (as they're formatted on Anaconda, anyway).
  version = "v8.0.0_6959_g${rev}";

  src = fetchFromGitHub {
    owner = "verilog-to-routing";
    repo = "vtr-verilog-to-routing";
    inherit rev;
    hash = "sha256-deGnquGWXibkzkgB2gWcJ8SojV38kvSUpx7v0RIRRnI=";
  };

  patches = [
    ./no-wget.patch
    ./fix-symlinks.patch # TODO upstream
    ./ignore-non-synth.patch # TODO upstream
    (fetchpatch {
      url = "https://github.com/verilog-to-routing/vtr-verilog-to-routing/pull/2438.patch";
      hash = "sha256-v9S59GrjOpwXhmdzYuikAXCMkkDYKY//fKvT6cyxIEE=";
    })
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
    flex
    pkg-config
  ];
  buildInputs = [
    eigen
    zlib
  ] ++ lib.optionals enableTbb [ tbb_2021_11 ];

  doCheck = true;

  meta = {
    description = "Open Source CAD Flow for FPGA Research";
    homepage = "https://verilogtorouting.org/";
    # Note that ABC (which is included)'s license isn't MIT (although it's similar);
    # but nixpkgs's ABC calls it the MIT license so it's probably fine?
    license = lib.licenses.mit;
  };
}
