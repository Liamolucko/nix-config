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
  pname = "litescope";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litescope";
    rev = version;
    hash = "sha256-VqelBmeIdLEhcEcVu6BTw54UqkwQ6zIAfH3M+kLd0b0=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ litex ];

  nativeCheckInputs = [ unittestCheckHook ];
  preCheck = ''
    rm test/test_examples.py # Depends on litex-boards.
  '';

  meta = with lib; {
    description = "Small footprint and configurable embedded FPGA logic analyzer";
    homepage = "https://github.com/enjoy-digital/litescope";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
