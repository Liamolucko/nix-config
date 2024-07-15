{
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  rev = "0a0adde";
in
stdenv.mkDerivation {
  pname = "prjxray-db";
  # This isn't some weird pre-release version, the commit hash is actually part of
  # the version number (as they're formatted on Anaconda, anyway).
  version = "0.0_257_g${rev}";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray-db";
    inherit rev;
    hash = "sha256-cU30ZtT+Olkcxzf/vopCT2d4IBG5vU9K3hHIvvy466c=";
  };

  # This ends up accidentally triggering `make clean-artix7-db`.
  dontBuild = true;
  installPhase = ''
    mkdir $out
    cp -r artix7 kintex7 spartan7 zynq7 $out
  '';

  meta = {
    description = "Project X-Ray Database: XC7 Series";
    homepage = "https://github.com/f4pga/prjxray-db";
    licence = lib.licenses.cc0;
  };
}
