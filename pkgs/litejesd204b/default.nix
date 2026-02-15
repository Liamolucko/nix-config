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
  pname = "litejesd204b";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litejesd204b";
    tag = finalAttrs.version;
    hash = "sha256-tcvHAQoC2TM60zgBh8Ng4O0YEBId6xG4xaOCJTzOhEY=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable JESD204B core";
    homepage = "https://github.com/enjoy-digital/litejesd204b";
    license = lib.licenses.bsd2;
  };
})
