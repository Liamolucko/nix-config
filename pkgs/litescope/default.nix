{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "litescope";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litescope";
    tag = finalAttrs.version;
    hash = "sha256-bHA7tmQkeNgabqMHeVpGlaplsToWcDaJU+yG3LzcBWU=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  preCheck = ''
    rm test/test_examples.py # Depends on litex-boards.
  '';

  meta = {
    description = "Small footprint and configurable embedded FPGA logic analyzer";
    homepage = "https://github.com/enjoy-digital/litescope";
    license = lib.licenses.bsd2;
  };
})
