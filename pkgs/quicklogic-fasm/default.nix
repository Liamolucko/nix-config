{
  lib,
  python3,
  fetchFromGitHub,
}:

# TODO: since one of the ways you're supposed to use this is with python3 -m, it should probablty use buildPythonPackage.
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

  meta = {
    description = "Tools, scripts and resources for generating a bitstream from the FASM files for the QuickLogic FPGAs";
    homepage = "https://github.com/antmicro/quicklogic-fasm";
    license = lib.licenses.asl20;
    mainProgram = "quicklogic-fasm";
  };
}
