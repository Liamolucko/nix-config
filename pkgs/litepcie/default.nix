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

buildPythonPackage rec {
  pname = "litepcie";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litepcie";
    rev = version;
    hash = "sha256-oH4ATlgs+4R3qSjE0Z+23wQh8PgW8UYiiP7CVbp1Oh0=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/enjoy-digital/litepcie/commit/f8b1599bdbe7adb986384308afb62b1f2d040be8.patch";
      hash = "sha256-hIuZq+5tgjqYZw60laVgdFwnpBVeXzu5b5qySBsJXDY=";
    })
  ];

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
}
