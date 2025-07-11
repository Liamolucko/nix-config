{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  migen,
  packaging,
  pexpect,
  pyserial,
  requests,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "litex";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litex";
    rev = version;
    hash = "sha256-gDg2QXrC6HJ316tCrNC/1/kZK/+H5iGtm9YN4FubDXI=";
  };

  build-system = [ setuptools ];
  dependencies = [
    migen
    packaging
    pyserial
    requests
  ];

  nativeCheckInputs = [
    pexpect
    unittestCheckHook
  ];
  preCheck = ''
    # These two tests rely on litedram, which would be a circular dependency.
    #
    # For some reason unittest doesn't have an option to ignore tests, only to
    # filter them with a syntax that's too limited to narrow it down to one file:
    # so, just delete the tests we want to skip.
    rm test/test_{ecc,cpu}.py
  '';

  meta = {
    description = "Build your hardware, easily";
    homepage = "https://github.com/enjoy-digital/litex";
    changelog = "https://github.com/enjoy-digital/litex/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.bsd2;
  };
}
