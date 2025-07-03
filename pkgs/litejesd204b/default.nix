{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litejesd204b";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litejesd204b";
    rev = version;
    hash = "sha256-Z5h1C+TIpLtcRzUM2tnvqvV2TF0WOcW+L2IjyZ+j1HA=";
  };

  build-system = [ setuptools ];
  dependencies = [ litex ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable JESD204B core";
    homepage = "https://github.com/enjoy-digital/litejesd204b";
    license = lib.licenses.bsd2;
  };
}
