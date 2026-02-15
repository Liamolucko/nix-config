{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch,
  setuptools,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "litepcie";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litepcie";
    tag = finalAttrs.version;
    hash = "sha256-Wi/gV7NmLOu8rLNWn4kECcB6gfdlOjOJQy64dwx0Dks=";
  };

  build-system = [ setuptools ];
  dependencies = [
    pyyaml
    litex
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  preCheck = ''
    rm test/test_examples.py # Depends on litex-boards.
  '';

  meta = {
    description = "Small footprint and configurable PCIe core";
    homepage = "https://github.com/enjoy-digital/litepcie";
    license = lib.licenses.bsd2;
  };
})
