{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "quicklogic-fasm";
  version = "0-unstable-2020-07-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "quicklogic-fasm";
    rev = "fafa623486f37301821cd29683a2c7a118115ff1";
    hash = "sha256-jyCxoQRWuHKKm2auxsLzKD2Q5IJuzoPZ0iqvw6A7OSw=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];
  dependencies = [
    python3.pkgs.fasm
    python3.pkgs.fasm-utils
  ];

  pythonImportsCheck = [ "quicklogic_fasm" ];

  meta = with lib; {
    description = "Tools, scripts and resources for generating a bitstream from the FASM files for the QuickLogic FPGAs";
    homepage = "https://github.com/antmicro/quicklogic-fasm";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "quicklogic-fasm";
  };
}
