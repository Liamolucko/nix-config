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

buildPythonPackage (finalAttrs: {
  pname = "litex";
  version = "2025.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litex";
    tag = finalAttrs.version;
    hash = "sha256-KtIKB6FAqVKjZXLNG9uV8QjLJqDI3qT2x0XXnE+3aRs=";
  };

  patches = [
    ./picolibc-writable.patch
    ./pypy.patch
  ];

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
    rm test/test_{ecc,integration}.py
  '';

  meta = {
    description = "Build your hardware, easily";
    homepage = "https://github.com/enjoy-digital/litex";
    changelog = "https://github.com/enjoy-digital/litex/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.bsd2;
  };
})
