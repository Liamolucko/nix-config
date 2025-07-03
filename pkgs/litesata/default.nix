{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  litex,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litesata";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litesata";
    rev = version;
    hash = "sha256-Bl/y0EMZAk1C+/LBQasiogelmqW7hM5Y4gUe38fisQE=";
  };

  build-system = [ setuptools ];
  dependencies = [ litex ];

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
}
