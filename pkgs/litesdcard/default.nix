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
  pname = "litesdcard";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litesdcard";
    tag = finalAttrs.version;
    hash = "sha256-ELIvG3sX2BQPLRuQx2LJYqnv0EYO102YoHbd0w9t+i8=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable SDCard core";
    homepage = "https://github.com/enjoy-digital/litesdcard";
    license = lib.licenses.bsd2;
  };
})
