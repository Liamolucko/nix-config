{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  liteiclink,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "liteeth";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "liteeth";
    rev = version;
    hash = "sha256-atXa/rX9/w2wbNqVPdIB2eMTG7dSq+cfM3iffrGnAyo=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [
    liteiclink
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = with lib; {
    description = "Small footprint and configurable Ethernet core";
    homepage = "https://github.com/enjoy-digital/liteeth";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
