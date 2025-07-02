{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools_scm,
  wheel,
  ply,
  pyjson,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "sdf-timing";
  version = "0.0.post131";
  pyproject = true;

  src = fetchPypi {
    pname = "sdf_timing";
    inherit version;
    hash = "sha256-KuCRxQASmaBcIE8PJNcCFT2aHuMMYzYia6+G5LEReOg=";
  };

  # TODO: upstream
  patches = [ ./no-dev-deps.patch ];

  build-system = [
    setuptools
    setuptools_scm
    wheel
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
