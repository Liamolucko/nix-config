{
  lib,
  stdenv,
  fetchurl,
  symlinkJoin,
  timestamp ? "20220907-210059",
  rev ? "66a976d",
}:
let
  fetchPkg =
    {
      pkg,
      hash,
      family,
    }:
    stdenv.mkDerivation rec {
      pname = "f4pga-arch-defs-${pkg}";
      version = timestamp;

      src = fetchurl {
        url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${timestamp}/symbiflow-arch-defs-${pkg}-${rev}.tar.xz";
        inherit hash;
      };
      sourceRoot = "share";

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/${family}"
        cp -r . "$out/${family}/share"
        runHook postInstall
      '';

      meta = {
        description = "FOSS architecture definitions of FPGA hardware useful for doing PnR device generation";
        homepage = "https://github.com/f4pga/f4pga-arch-defs";
        licence = lib.licenses.isc;
      };
    };

  install-xc7 = fetchPkg {
    pkg = "install-xc7";
    hash = "sha256-j6GqnPwDPJ/vWcKsGdT/GFaKZryM4Vwzhc2ewdGQEnQ=";
    family = "xc7";
  };
  xc7a50t_test = fetchPkg {
    pkg = "xc7a50t_test";
    hash = "sha256-gZ6dVMkYKGlWIBREv3i0gq6UsyAukAw99ZPQEsFY108=";
    family = "xc7";
  };
  xc7a100t_test = fetchPkg {
    pkg = "xc7a100t_test";
    hash = "sha256-SbNV6KRC5GZSx7CJwj3AINS6u4AJ2PRJTgnXLjey5e8=";
    family = "xc7";
  };
  xc7a200t_test = fetchPkg {
    pkg = "xc7a200t_test";
    hash = "sha256-dfZnaWSoaUXSrE8dKLERJ2TE5EZA6GJ1jTcuICOracc=";
    family = "xc7";
  };
  xc7z010_test = fetchPkg {
    pkg = "xc7z010_test";
    hash = "sha256-um953QtcSCPvPG6K/CuiNYNkElMYDs7CImaI4h194sE=";
    family = "xc7";
  };

  install-ql-eos-s3 = fetchPkg {
    pkg = "install-ql";
    hash = "sha256-lDsFwz2cnuV7JRGUaree2ErUOYhUMt1QdFgjC2GzipQ=";
    family = "eos-s3";
  };
  install-ql-qlf_k4n8 = fetchPkg {
    pkg = "install-ql";
    hash = "sha256-lDsFwz2cnuV7JRGUaree2ErUOYhUMt1QdFgjC2GzipQ=";
    family = "qlf_k4n8";
  };
  ql-eos-s3_wlcsp = fetchPkg {
    pkg = "ql-eos-s3_wlcsp";
    hash = "sha256-5zo1emcx8X4M69sjg9Id6Sur/8CzZa2lWmcmYceakyU=";
    family = "eos-s3";
  };
in
{
  inherit
    fetchPkg
    install-xc7
    install-ql-eos-s3
    install-ql-qlf_k4n8
    ;

  # Package each FPGA architecture up together with its corresponding `install`.
  xc7a50t = symlinkJoin {
    name = "f4pga-arch-defs-xc7a50t";
    paths = [
      install-xc7
      xc7a50t_test
    ];
  };
  xc7a100t = symlinkJoin {
    name = "f4pga-arch-defs-xc7a100t";
    paths = [
      install-xc7
      xc7a100t_test
    ];
  };
  xc7a200t = symlinkJoin {
    name = "f4pga-arch-defs-xc7a200t";
    paths = [
      install-xc7
      xc7a200t_test
    ];
  };
  xc7z010 = symlinkJoin {
    name = "f4pga-arch-defs-xc7z010";
    paths = [
      install-xc7
      xc7z010_test
    ];
  };

  ql-eos-s3 = symlinkJoin {
    name = "f4pga-arch-defs-ql-eos-s3";
    paths = [
      install-ql-eos-s3
      ql-eos-s3_wlcsp
    ];
  };
}
