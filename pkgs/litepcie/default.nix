{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
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

  build-system = [
    setuptools
    wheel
  ];
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
