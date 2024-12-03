{
  lib,
  # This doesn't work with Python 3.12 because it relies on distutils.
  python311,
  fetchFromGitHub,
  yosys,
}:

python311.pkgs.buildPythonApplication {
  pname = "v2x";
  version = "0-unstable-2022-05-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-v2x";
    rev = "413dc2743cd35f3745165a31636af380b3b3448a";
    hash = "sha256-oSfEzRcjWTCR82M4cCn+WTNH/3Xq4AcifMShFuW+Zgs=";
  };

  patches = [ ./no-pytest-runner.patch ];

  build-system = [
    python311.pkgs.setuptools
    python311.pkgs.wheel
  ];

  dependencies = [
    python311.pkgs.lxml
    python311.pkgs.pyjson
    python311.pkgs.vtr-xml-utils
  ];

  nativeCheckInputs = [
    python311.pkgs.pytestCheckHook
    yosys
  ];
  # This test relies on the precise output of yosys, and now fails because it's
  # changed over the years.
  disabledTests = [ "test_pbtype_generation_with_vlog_to_pbtype" ];

  meta = {
    description = "Tool for converting specialized annotated Verilog models into XML needed for Verilog to Routing flow";
    homepage = "https://github.com/chipsalliance/f4pga-v2x";
    license = lib.licenses.asl20;
    mainProgram = "v2x";
  };
}
