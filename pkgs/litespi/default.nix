{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  litex,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litespi";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litespi";
    rev = version;
    hash = "sha256-ri4Kqr62mP6sviq3FwYGGtaZxe1yR0BEWW+5dwmkJ+g=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ litex ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = with lib; {
    description = "Small footprint and configurable SPI core";
    homepage = "https://github.com/litex-hub/litespi";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
