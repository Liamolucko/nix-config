{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  colorama,
  cython,
}:
buildPythonPackage rec {
  pname = "pyjson5";
  version = "1.6.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IN+MXbvg1lP0A9qIt1IL5E/I10aXu90erWiEWLVpGgI=";
  };

  build-system = [
    setuptools
    wheel
    cython
  ];

  nativeCheckInputs = [ colorama ];
  checkPhase = ''
    python scripts/run-minefield-test.py
    python scripts/run-tests.py
  '';

  meta = {
    description = "A JSON5 serializer and parser library for Python 3 written in Cython";
    homepage = "https://github.com/Kijewski/pyjson5";
    license = lib.licenses.asl20;
  };
}
