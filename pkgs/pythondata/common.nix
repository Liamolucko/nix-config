{
  kind,
  name,
  hash,
  license,
  dependencies ? pkgs: [ ],
  doCheck ? true,
}:
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
}:
let
  dashedName = builtins.replaceStrings [ "_" ] [ "-" ] name;
in
buildPythonPackage (finalAttrs: {
  pname = "pythondata-${kind}-${dashedName}";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "pythondata-${kind}-${name}";
    tag = finalAttrs.version;
    inherit hash;
    fetchSubmodules = true;
  };

  build-system = [ setuptools ];
  dependencies = dependencies python.pkgs;

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
})
