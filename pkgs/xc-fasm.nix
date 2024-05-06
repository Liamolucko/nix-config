{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  intervaltree,
  simplejson,
  textx,
  prjxray,
  fasm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "xc-fasm";
  version = "unstable-2022-02-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-xc-fasm";
    rev = "25dc605c9c0896204f0c3425b52a332034cf5e5c";
    hash = "sha256-QzBL759yS2TwWmN0FG+WIWhTjhvzLVSYHatYlQgkxW4=";
  };

  patches = [ ./xc-fasm.patch ];

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    intervaltree
    simplejson
    textx
    prjxray
    fasm
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/chipsalliance/f4pga-xc-fasm";
    license = licenses.asl20;
  };
}
