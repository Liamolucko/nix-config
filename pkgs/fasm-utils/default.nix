{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "fasm-utils";
  version = "0-unstable-2021-03-05";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "quicklogic-fasm-utils";
    rev = "3d6a375ddb6b55aaa5a59d99e44a207d4c18709f";
    hash = "sha256-wHSOU+GaCGZtYqwze8+7fgerJ0aUlpL0NIzcCoQgKU8=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "fasm_utils" ];

  meta = {
    description = "Set of tools for creating FASM assemblers for the Symbiflow project";
    homepage = "https://github.com/QuickLogic-Corp/quicklogic-fasm-utils";
    license = lib.licenses.asl20;
  };
}
