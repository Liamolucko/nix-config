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
  pname = "liteiclink";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "liteiclink";
    tag = finalAttrs.version;
    hash = "sha256-hniCGn4+akpEEFcK84H4pxwX8M+Ku/O7MDK8L670aSs=";
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
})
