{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
}:

buildPythonPackage (finalAttrs: {
  pname = "litei2c";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litei2c";
    tag = finalAttrs.version;
    hash = "sha256-0sTjGzb/FmGtywsFEm+BoieTLoYiQ5wVxKCTHQW/CjQ=";
  };

  patches = [ ./add-inits.patch ];

  build-system = [ setuptools ];

  dependencies = [ litex ];

  pythonImportsCheck = [
    "litei2c"
  ];

  meta = {
    description = "Small footprint and configurable I2C core";
    homepage = "https://github.com/litex-hub/litei2c";
    license = lib.licenses.bsd2;
  };
})
