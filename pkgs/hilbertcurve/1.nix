{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hilbertcurve";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "galtay";
    repo = "hilbertcurve";
    rev = "v${version}";
    hash = "sha256-fY5WD8qCj01VXo4j66qZ4aFHDw6jFFB4codmpJF8nqQ=";
  };

  build-system = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Maps between 1-D space filling hilbert curve and N-D coordinates";
    homepage = "https://github.com/galtay/hilbertcurve";
    license = lib.licenses.mit;
  };
}
