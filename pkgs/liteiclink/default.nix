{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "liteiclink";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "liteiclink";
    rev = version;
    hash = "sha256-mnQBD9Paw94t+624ClHAJ9JS4aA09WA1RQvzD5QYXNo=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  # Disable test_serwb_core.py, since it has a circular dependency on liteeth.
  unittestFlagsArray = [
    "-p"
    "test_serwb_init.py"
  ];

  meta = {
    description = "Small footprint and configurable Inter-Chip communication cores";
    homepage = "https://github.com/enjoy-digital/liteiclink";
    license = lib.licenses.bsd2;
  };
}
