{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
let
  rev = "c6f57643";
in
stdenv.mkDerivation {
  pname = "prjxray-tools";
  # This isn't some weird pre-release version, the commit hash is actually part of
  # the version number (as they're formatted on Anaconda, anyway).
  version = "0.1_3252_g${rev}";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    inherit rev;
    hash = "sha256-nfbbOR+sS6qXRJad/31Le+4gPPh/psAIeSeu6wnS7gM=";
    fetchSubmodules = true;
  };
  patches = [ ./no-abs-bash.patch ];

  nativeBuildInputs = [ cmake ];

  # We should be running test-cpp as well, but the tests aren't run in CI so
  # they've bitrotted and don't compile.
  checkPhase = ''
    make -C .. test-tools
  '';
  doCheck = true;

  meta = {
    description = "Documenting the Xilinx 7-series bit-stream format";
    homepage = "https://github.com/f4pga/prjxray";
    licence = lib.licenses.isc;
  };
}
