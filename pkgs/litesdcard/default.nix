{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litesdcard";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litesdcard";
    rev = version;
    hash = "sha256-s/kSPDOW/GV4Ejqcj7E0Eee44J7auT3xmG/9m7s2YKI=";
  };

  build-system = [ setuptools ];
  dependencies = [ litex ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable SDCard core";
    homepage = "https://github.com/enjoy-digital/litesdcard";
    license = lib.licenses.bsd2;
  };
}
