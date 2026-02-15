{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "litesata";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litesata";
    tag = finalAttrs.version;
    hash = "sha256-rEzZZuueRSP5//8M4CV5xpL1VZASsflTMK5Yo83mnu0=";
  };

  build-system = [ setuptools ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  preCheck = ''
    # Rebuild these x86_64-linux binaries for the current platform.
    ${lib.getExe stdenv.cc} test/model/crc.c -o test/model/crc
    ${lib.getExe stdenv.cc} test/model/scrambler.c -o test/model/scrambler
  '';

  meta = {
    description = "Small footprint and configurable SATA core";
    homepage = "https://github.com/enjoy-digital/litesata";
    license = lib.licenses.bsd2;
  };
})
