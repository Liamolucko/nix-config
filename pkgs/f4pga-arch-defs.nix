# TODO make this a single callPackage invocation which then returns another function accepting `{ pkg, hash }`
{
  lib,
  stdenv,
  fetchurl,
  pkg,
  timestamp ? "20220907-210059",
  rev ? "66a976d",
  hash,
}:
stdenv.mkDerivation rec {
  pname = "f4pga-arch-defs-${pkg}";
  # TODO switch to using timestamp as the version number
  version = rev;

  src = fetchurl {
    url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${timestamp}/symbiflow-arch-defs-${pkg}-${rev}.tar.xz";
    inherit hash;
  };
  # install-xc7 comes with an extraneous `xc7_env` folder which confuses stdenv,
  # tell it to ignore it and just use `share`.
  sourceRoot = "share";

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/share
    runHook postInstall
  '';

  meta = {
    description = "FOSS architecture definitions of FPGA hardware useful for doing PnR device generation";
    homepage = "https://github.com/f4pga/f4pga-arch-defs";
    licence = lib.licenses.isc;
  };
}
