{
  lib,
  pkgs,
  pkgsCross,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  json_c,
  libevent,
  litex,
  ninja,
  pexpect,
  pythondata-cpu-serv,
  pythondata-cpu-vexriscv,
  pythondata-misc-tapcfg,
  pythondata-software-compiler-rt,
  pythondata-software-picolibc,
  pyyaml,
  unittestCheckHook,
  verilator,
  zlib,
}:

buildPythonPackage rec {
  pname = "litedram";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enjoy-digital";
    repo = "litedram";
    rev = version;
    hash = "sha256-YcLxKFEVnfk9ocFIOx0pnKkrM23GXbnssXvLtHZpJP8=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [
    litex
    pyyaml
  ];

  nativeCheckInputs = [
    pkgs.meson # Use the normal version of meson, not the python package.
    ninja
    pexpect
    pythondata-cpu-serv
    pythondata-cpu-vexriscv
    pythondata-misc-tapcfg
    pythondata-software-compiler-rt
    pythondata-software-picolibc
    unittestCheckHook
    verilator
    # Every instance of nixpkgs has a build, host and target platform that it gives
    # to all its derivations (let's write that build -> host -> target).
    #
    # If pkgs is build -> host -> target, then `pkgs.pkgs<x><y>`, where x and y are
    # Build, Host, or Target, produces a new nixpkgs which is
    # build -> pkgs[x] -> pkgs[y], where pkgs[x] is a made up notation for getting
    # one of pkgs' platforms: so pkgs[Build] = build.
    #
    # If this derivation is build -> host -> target, then pkgsCross.riscv64-embedded
    # is build -> riscv64-none-elf -> riscv64-none-elf, and then pkgsBuildHost lets
    # us shift everything right by one to get build -> build -> riscv64-none-elf
    # like we want.
    #
    # pkgsBuildHost is also known as buildPackages: another way to think about it is
    # that the compiler we want for this is the same compiler we'd need to build a
    # package that was actually going to run on RISC-V.
    pkgsCross.riscv64-embedded.buildPackages.gcc
  ];

  dontUseMesonConfigure = true;
  dontUseMesonCheck = true;
  dontUseMesonInstall = true;

  checkInputs = [
    json_c
    libevent
    zlib
  ];

  # Disable:
  # - test_init.py, since it relies on litex-boards.
  # - test_phy_utils.py, since it seems to trigger another issue with Migen's
  #   tracer in Python 3.11 that https://github.com/m-labs/migen/commit/0fb91737090fe45fd764ea3f71257a4c53c7a4ae
  #   didn't fix.
  unittestFlagsArray = [
    "-p"
    # Seems like broken shell escaping.
    "'test_[!ip]*'"
  ];

  meta = {
    description = "Small footprint and configurable DRAM core";
    homepage = "https://github.com/enjoy-digital/litedram";
    license = lib.licenses.bsd2;
  };
}
