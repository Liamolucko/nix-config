{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  litex,
}:

buildPythonPackage rec {
  pname = "valentyusb";
  version = "2023.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "valentyusb";
    rev = version;
    hash = "sha256-f8XMupO3Y4peHhFJmWG1BFL8vGRqjYXeyNsoiVf5xd0=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ litex ];

  # The unit tests in sim/ are broken.
  #
  # We could maybe use https://github.com/antmicro/usb-test-suite-testbenches
  # as a `passthru.tests` test, but eh.
  pythonImportsCheck = [ "valentyusb" ];

  meta = {
    description = "FPGA USB stack written in LiteX";
    homepage = "https://github.com/litex-hub/valentyusb";
    license = lib.licenses.bsd3;
  };
}
