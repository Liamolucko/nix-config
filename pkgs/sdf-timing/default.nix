{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools_scm,
  wheel,
  yapf,
  tox,
  ply,
  pyjson,
  pytestCheckHook,
}:
let
  yapf_0_24 = yapf.overridePythonAttrs rec {
    version = "0.24.0";
    src = fetchPypi {
      pname = "yapf";
      inherit version;
      hash = "sha256-zrtvrzXJAnwImWwHgxuJcfPWfA62FSafZt/X5oFf3Co=";
    };
    # Some tests fail with Python 3.12.
    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "sdf-timing";
  version = "0.0.post131";
  pyproject = true;

  src = fetchPypi {
    pname = "sdf_timing";
    inherit version;
    hash = "sha256-KuCRxQASmaBcIE8PJNcCFT2aHuMMYzYia6+G5LEReOg=";
  };

  build-system = [
    setuptools
    setuptools_scm
    wheel
    tox
    yapf_0_24
  ];

  dependencies = [
    ply
    pyjson
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Python library for working Standard Delay Format (SDF) Timing Annotation files";
    homepage = "https://github.com/chipsalliance/python-sdf-timing";
    license = lib.licenses.asl20;
  };
}
