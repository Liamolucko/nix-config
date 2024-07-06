{
  lib,
  python3,
  fetchFromGitHub,
  yosys,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "v2x";
  version = "0-unstable-2022-05-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga-v2x";
    rev = "413dc2743cd35f3745165a31636af380b3b3448a";
    hash = "sha256-oSfEzRcjWTCR82M4cCn+WTNH/3Xq4AcifMShFuW+Zgs=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = [
    python3.pkgs.lxml
    python3.pkgs.pyjson
    python3.pkgs.vtr-xml-utils
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
    python3.pkgs.pytest-runner
    yosys
  ];
  # This test relies on the precise output of yosys, and now fails because it's
  # changed over the years.
  disabledTests = [ "test_pbtype_generation_with_vlog_to_pbtype" ];

  meta = with lib; {
    description = "Tool for converting specialized annotated Verilog models into XML needed for Verilog to Routing flow";
    homepage = "https://github.com/chipsalliance/f4pga-v2x";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "v2x";
  };
}
