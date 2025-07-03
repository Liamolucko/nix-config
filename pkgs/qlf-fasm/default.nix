{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "qlf-fasm";
  version = "0-unstable-2021-06-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "ql_fasm";
    rev = "e5d09154df9b0c6d1476ac578950ec95abb8ed86";
    hash = "sha256-jciXhME/EXV50xBOq2mAfc/bPNEJYZ+TFU7F91wTjfY=";
  };

  build-system = [ python3.pkgs.setuptools ];
  dependencies = [ python3.pkgs.fasm ];

  # TODO: some tests are currently being skipped because QLF_FASM_DB_ROOT is unset.
  nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];

  meta = {
    description = "FASM to/from bitstream converter for QuickLogic qlf FPGA device family";
    homepage = "https://github.com/QuickLogic-Corp/ql_fasm";
    license = lib.licenses.asl20;
    mainProgram = "qlf-fasm";
  };
}
