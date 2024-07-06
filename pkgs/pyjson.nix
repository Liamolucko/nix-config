{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyjson";
  version = "1.4.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eevlXMy2IkMCusqfcRmSfHPcscGMP+0ZPbgM+zINDKY=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "pyjson" ];

  meta = with lib; {
    description = "Compare the similarities between two JSONs";
    homepage = "https://pypi.org/project/pyjson";
    license = licenses.mit;
  };
}
