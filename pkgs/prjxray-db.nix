{
  lib,
  stdenv,
  fetchFromGitHub,
  runCommand,
  writeShellScript,
}:
let
  pname = "prjxray-db";
  rev = "0a0adde";
  # This isn't some weird pre-release version, the commit hash is actually part of
  # the version number (as they're formatted on Anaconda, anyway).
  version = "0.0_257_g${rev}";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray-db";
    inherit rev;
    hash = "sha256-cU30ZtT+Olkcxzf/vopCT2d4IBG5vU9K3hHIvvy466c=";
  };
  data = runCommand "prjxray-db-data" { } ''
    mkdir -p $out
    cp -r ${src}/{artix7,kintex7,spartan7,zynq7} $out
  '';
  prjxray-config = writeShellScript "prjxray-config" ''
    echo '${data}'
  '';
in
runCommand "${pname}-${version}"
  {
    inherit pname version;

    meta = {
      description = "Project X-Ray Database: XC7 Series";
      homepage = "https://github.com/f4pga/prjxray-db";
      licence = lib.licenses.cc0;
    };
  }
  ''
    mkdir -p $out/bin
    cp '${prjxray-config}' $out/bin/prjxray-config
  ''
