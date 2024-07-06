{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
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

  build-system = [
    setuptools
    wheel
  ];
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

  meta = with lib; {
    description = "Build your hardware, easily";
    homepage = "https://github.com/enjoy-digital/litex";
    changelog = "https://github.com/enjoy-digital/litex/blob/${src.rev}/CHANGES.md";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
