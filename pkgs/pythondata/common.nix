{
  kind,
  name,
  hash,
  license,
  doCheck ? true,
}:
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  wheel,
}:
let
  dashedName = builtins.replaceStrings [ "_" ] [ "-" ] name;
in
buildPythonPackage rec {
  pname = "pythondata-${kind}-${dashedName}";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "pythondata-${kind}-${name}";
    rev = version;
    inherit hash;
    fetchSubmodules = true;
  };

  build-system = [
    setuptools
    wheel
  ];

  inherit doCheck;
  # TODO: cd into $out so that the version in /tmp/nix-build-* isn't accessible (same as pythonImportsCheck).
  checkPhase = ''
    runHook preCheck
    ${python.interpreter} test.py
    runHook postCheck
  '';

  meta = {
    description = "Python module containing data files for ${name} ${kind} (for use with LiteX)";
    homepage = "https://github.com/litex-hub/pythondata-${kind}-${name}";
    license = license lib.licenses;
  };
}
