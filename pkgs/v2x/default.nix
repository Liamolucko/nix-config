{
  lib,
  python3,
  fetchFromGitHub,
  fetchpatch,
  yosys,
}:

python3.pkgs.buildPythonApplication {
  pname = "v2x";
  version = "0-unstable-2022-05-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-v2x";
    rev = "413dc2743cd35f3745165a31636af380b3b3448a";
    hash = "sha256-oSfEzRcjWTCR82M4cCn+WTNH/3Xq4AcifMShFuW+Zgs=";
  };

  patches = [
    ./no-pytest-runner.patch
    ./select-boxed.patch
    # TODO: double-check these, right now I've just blindly copy-pasted the actual
    # results even though there's some preprocessing occuring, plus there's some
    # weird stuff with things being inlined
    ./update-golden.patch
    (fetchpatch {
      url = "https://github.com/chipsalliance/f4pga-v2x/commit/ece275bb49d1a6f50d886c577d7bccecfe8f5f85.diff";
      hash = "sha256-KvwVxkU0EYwNwAUWNhMlX1odRH+wDaDZ+UDP2SncvR4=";
    })
  ];

  build-system = [ python3.pkgs.setuptools ];

  dependencies = [
    python3.pkgs.lxml
    python3.pkgs.pyjson
    python3.pkgs.vtr-xml-utils
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
    yosys
  ];

  meta = {
    description = "Tool for converting specialized annotated Verilog models into XML needed for Verilog to Routing flow";
    homepage = "https://github.com/chipsalliance/f4pga-v2x";
    license = lib.licenses.asl20;
    mainProgram = "v2x";
  };
}
