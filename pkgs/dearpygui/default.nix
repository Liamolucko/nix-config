{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  pytestCheckHook,
  setuptools,
  tkinter,
}:

buildPythonPackage rec {
  pname = "dearpygui";
  version = "2.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hoffstadt";
    repo = "DearPyGui";
    tag = "v${version}";
    hash = "sha256-andIM3xq+pvUVPsR1vDvkmxyjrYCQdqfAJp1JxnmqHs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  build-system = [ setuptools ];

  dontUseCmakeConfigure = true;

  nativeCheckInputs = [
    pytestCheckHook
    tkinter
  ];
  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    enabledTestPaths=$PWD/testing/simple_tests.py
    pushd "$out"
  '';
  postCheck = ''
    popd
  '';

  meta = {
    description = "Modern, fast and powerful GUI framework for Python";
    homepage = "https://github.com/hoffstadt/DearPyGui";
    changelog = "https://github.com/hoffstadt/DearPyGui/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Liamolucko ];
  };
}
