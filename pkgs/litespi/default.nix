{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "litespi";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litespi";
    tag = finalAttrs.version;
    hash = "sha256-qh4ehg+cTyWCQAOaa6YMV3ItYtc7UINnERS2puhd11Q=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable SPI core";
    homepage = "https://github.com/litex-hub/litespi";
    license = lib.licenses.bsd2;
  };
})
