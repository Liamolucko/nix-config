{
  lib,
  stdenv,
  fetchurl,
  runCommand,
  timestamp ? "20220907-210059",
  rev ? "66a976d",
}:
let
  fetchPkg =
    {
      pkg,
      root,
      hash,
    }:
    stdenv.mkDerivation rec {
      pname = "f4pga-arch-defs-${pkg}";
      version = timestamp;

      src = fetchurl {
        url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${timestamp}/symbiflow-arch-defs-${pkg}-${rev}.tar.xz";
        inherit hash;
      };
      sourceRoot = root;

      installPhase = ''
        runHook preInstall
        cp -r . $out
        runHook postInstall
      '';

      passthru = {
        inherit root;
      };

      meta = {
        description = "FOSS architecture definitions of FPGA hardware useful for doing PnR device generation";
        homepage = "https://github.com/f4pga/f4pga-arch-defs";
        licence = lib.licenses.isc;
      };
    };

  install-xc7 = fetchPkg {
    pkg = "install-xc7";
    hash = "sha256-j6GqnPwDPJ/vWcKsGdT/GFaKZryM4Vwzhc2ewdGQEnQ=";
    root = "share/f4pga/techmaps/xc7_vpr";
  };
  xc7a50t_test = fetchPkg {
    pkg = "xc7a50t_test";
    hash = "sha256-gZ6dVMkYKGlWIBREv3i0gq6UsyAukAw99ZPQEsFY108=";
    root = "share/f4pga/arch/xc7a50t_test";
  };
  xc7a100t_test = fetchPkg {
    pkg = "xc7a100t_test";
    hash = "sha256-SbNV6KRC5GZSx7CJwj3AINS6u4AJ2PRJTgnXLjey5e8=";
    root = "share/f4pga/arch/xc7a100t_test";
  };
  xc7a200t_test = fetchPkg {
    pkg = "xc7a200t_test";
    hash = "sha256-dfZnaWSoaUXSrE8dKLERJ2TE5EZA6GJ1jTcuICOracc=";
    root = "share/f4pga/arch/xc7a200t_test";
  };
  xc7z010_test = fetchPkg {
    pkg = "xc7z010_test";
    hash = "sha256-um953QtcSCPvPG6K/CuiNYNkElMYDs7CImaI4h194sE=";
    root = "share/f4pga/arch/xc7z010_test";
  };

  install-ql-pp3 = fetchPkg {
    pkg = "install-ql";
    hash = "sha256-lDsFwz2cnuV7JRGUaree2ErUOYhUMt1QdFgjC2GzipQ=";
    root = "share/f4pga/techmaps/pp3";
  };
  install-ql-qlf_k4n8 = fetchPkg {
    pkg = "install-ql";
    hash = "sha256-lDsFwz2cnuV7JRGUaree2ErUOYhUMt1QdFgjC2GzipQ=";
    root = "share/f4pga/techmaps/qlf_k4n8";
  };
  ql-eos-s3_wlcsp = fetchPkg {
    pkg = "ql-eos-s3_wlcsp";
    hash = "sha256-5zo1emcx8X4M69sjg9Id6Sur/8CzZa2lWmcmYceakyU=";
    root = "share/f4pga/arch/ql-eos-s3_wlcsp";
  };
in
{
  inherit
    fetchPkg
    install-xc7
    install-ql-pp3
    install-ql-qlf_k4n8
    ;

  # Package each FPGA architecture up together with its corresponding `install`.
  xc7a50t = {
    family = "xc7";
    pkgs = [
      install-xc7
      xc7a50t_test
    ];
  };
  xc7a100t = {
    family = "xc7";
    pkgs = [
      install-xc7
      xc7a100t_test
    ];
  };
  xc7a200t = {
    family = "xc7";
    pkgs = [
      install-xc7
      xc7a200t_test
    ];
  };
  xc7z010 = {
    family = "xc7";
    pkgs = [
      install-xc7
      xc7z010_test
    ];
  };

  ql-eos-s3 = {
    family = "eos-s3";
    pkgs = [
      install-ql-pp3
      ql-eos-s3_wlcsp
    ];
  };

  installDir =
    archs:
    let
      pkgs = lib.unique (
        builtins.concatLists (
          builtins.map (
            arch:
            builtins.map (pkg: {
              path = "${arch.family}/${pkg.passthru.root}";
              contents = pkg;
            }) arch.pkgs
          ) archs
        )
      );
      cmds = builtins.map (pkg: ''
        mkdir -p "$out/$(dirname '${pkg.path}')"
        ln -s '${pkg.contents}' "$out"/'${pkg.path}'
      '') pkgs;
    in
    runCommand "f4pga-install-dir" { } (builtins.concatStringsSep "" cmds);
}
