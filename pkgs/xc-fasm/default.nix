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
  prjxray-tools,
  fasm,
  unittestCheckHook,
}:

# TODO: use buildPythonApplication instead
buildPythonPackage rec {
  pname = "xc-fasm";
  version = "0-unstable-2022-02-28";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-xc-fasm";
    rev = "25dc605c9c0896204f0c3425b52a332034cf5e5c";
    hash = "sha256-QzBL759yS2TwWmN0FG+WIWhTjhvzLVSYHatYlQgkxW4=";
  };

  patches = [
    ./no-path.patch
    ./dont-assume-textx.patch
  ];

  postPatch = ''
    substituteInPlace xc_fasm/xc_fasm.py \
      --subst-var-by xc7frames2bit ${prjxray-tools}/bin/xc7frames2bit
  '';

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

  meta = {
    description = "Library to convert FASM files to bitstream";
    homepage = "https://github.com/chipsalliance/f4pga-xc-fasm";
    license = lib.licenses.asl20;
  };
}
