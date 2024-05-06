{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  cython,
}:
buildPythonPackage rec {
  pname = "pyjson5";
  version = "1.6.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IN+MXbvg1lP0A9qIt1IL5E/I10aXu90erWiEWLVpGgI=";
  };

  pyproject = true;
  # For some reason it doesn't work if I use `build-system` here...
  nativeBuildInputs = [
    setuptools
    cython
  ];

  meta = {
    description = "A JSON5 serializer and parser library for Python 3 written in Cython";
    homepage = "https://github.com/Kijewski/pyjson5";
    license = lib.licenses.asl20;
  };
}
