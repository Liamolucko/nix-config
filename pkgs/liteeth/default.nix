{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  liteiclink,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "liteeth";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "liteeth";
    tag = finalAttrs.version;
    hash = "sha256-BMkMvp0LlBelkExVJhJO/3aB53Klkmg6rDe1INgz4vM=";
  };

  patches = [
    ./pypy.patch
  ];

  build-system = [ setuptools ];
  dependencies = [
    liteiclink
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];

  meta = {
    description = "Small footprint and configurable Ethernet core";
    homepage = "https://github.com/enjoy-digital/liteeth";
    license = lib.licenses.bsd2;
  };
})
