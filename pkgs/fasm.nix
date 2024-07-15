# TODO: possibly incorporate https://github.com/chipsalliance/fasm/pull/87
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  setuptools,
  wheel,
  antlr4_9,
  cython,
  jre_headless,
  textx,
}:
buildPythonPackage {
  pname = "fasm";
  version = "0.0.2.post100";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "fasm";
    # The PyPI release doesn't have any indication of which commit it corresponds to
    # (nor a source code download), but considering it was made on the same day as
    # this commit this is probably what it's built from.
    rev = "ffafe821bae68637fe46e36bcfd2a01b97cdf6f2";
    hash = "sha256-evOtRl2FYa+9VIGpOc9Az7qAHFwt5dmukrpMXPBTZ7o=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    jre_headless # TODO use jre_minimal instead
  ];
  buildInputs = [ antlr4_9.runtime.cpp ];

  build-system = [
    setuptools
    wheel
    cython
  ];
  dependencies = [ textx ];

  # setup.py drives the build, not cmake.
  dontUseCmakeConfigure = true;
  setupPyBuildFlags = [ "--antlr-runtime=shared" ];
  ANTLR4_RUNTIME_INCLUDE = "${antlr4_9.runtime.cpp.dev}/include/antlr4-runtime";
  # They're broken; seems like something's overwriting `dir()`.
  doCheck = false;

  meta = {
    description = "FPGA Assembly (FASM) Parser and Generator";
    homepage = "https://github.com/chipsalliance/fasm";
    license = lib.licenses.asl20;
  };
}
