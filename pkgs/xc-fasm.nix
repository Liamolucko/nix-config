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

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    intervaltree
    simplejson
    textx
    prjxray
    fasm
  ];

  pythonImportsCheck = [ "xc_fasm" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/chipsalliance/f4pga-xc-fasm";
    license = licenses.asl20;
  };
}
