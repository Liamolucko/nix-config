{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "tinyfpgab";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tinyfpga";
    repo = "TinyFPGA-B-Series";
    rev = "5ba7fec91e2459419404923a1460fc50801460e6";
    hash = "sha256-3GoBp//+8JaXnltoyEKw2kU8nMvU2ma0FK9S7FGhuD4=";
  };

  preConfigure = ''
    cd programmer
  '';

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];
  dependencies = [ python3.pkgs.pyserial ];

  nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];
  pytestFlagsArray = [ "test.py" ];

  meta = with lib; {
    description = "Programmer for the TinyFPGA B2 boards";
    homepage = "https://pypi.org/project/tinyfpgab";
    license = licenses.gpl3Only; # TODO should it be gpl3Plus? I don't see an 'or later' anywhere
    maintainers = with maintainers; [ ];
    mainProgram = "tinyfpgab";
  };
}
