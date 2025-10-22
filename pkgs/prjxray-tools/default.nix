{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation {
  pname = "prjxray-tools";
  # This isn't some weird pre-release version, the commit hash is actually part of
  # the version number (as they're formatted on Anaconda, anyway).
  version = "0.1-unstable-2025-04-06";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "d10061648752d34e650a0ebec54f3c0d46be42e5";
    hash = "sha256-dygOIBRAZGcd/xBkHDlGOztt4VPFtXo4MI5ljmmeJsI=";
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
