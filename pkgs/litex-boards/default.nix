{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  litex,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litex-boards";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litex-boards";
    rev = version;
    hash = "sha256-pHtVotOZDZKE4RGUIn2rZTCPBjpLiEJLuLyaOcDCQbg=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ litex ];

  # TODO: enable tests after we've packaged all the various other libraries in the litex ecosystem they rely on.
  # nativeCheckInputs = [ unittestCheckHook ];
  pythonImportsCheck = [ "litex_boards" ];

  meta = with lib; {
    description = "LiteX boards files";
    homepage = "https://github.com/litex-hub/litex-boards";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
