{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "quicklogic-timings-importer";
  version = "0-unstable-2020-08-13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "QuickLogic-Corp";
    repo = "quicklogic-timings-importer";
    rev = "eec0737d3345ebcb54e3c080a838e0e5f5526783";
    hash = "sha256-8KrAlkGmv/uAUpexMlvkKdpCqHsZhIz/pOYjIGdkOK4=";
  };

  build-system = [ python3.pkgs.setuptools ];
  dependencies = [
    python3.pkgs.sdf-timing
    python3.pkgs.termcolor
  ];

  pythonImportsCheck = [ "quicklogic_timings_importer" ];

  meta = {
    description = "Importer of timing data from Quicklogic EOS-S3 to SDF";
    homepage = "https://github.com/antmicro/quicklogic-timings-importer";
    license = lib.licenses.asl20;
    mainProgram = "quicklogic-timings-importer";
  };
}
