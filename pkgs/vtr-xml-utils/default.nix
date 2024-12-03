{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  lxml,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "vtr-xml-utils";
  version = "0-unstable-2022-02-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "vtr-xml-utils";
    rev = "0e46e820ffe3b873810d8fae6103c1c6bc452acd";
    hash = "sha256-pwsJwZALdnqt1Xz3VyggcEZRKpTTQTXBiaOiq8AZwZA=";
  };

  patches = [ ./no-pytest-runner.patch ];

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ lxml ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "Utilities for working with VtR XML Files";
    homepage = "https://github.com/chipsalliance/vtr-xml-utils";
    license = lib.licenses.asl20;
  };
}
