# For packages that don't have tagged versions, this is based on F4PGA release 8
# (see https://f4pga.readthedocs.io/en/latest/development/changes.html)
{
  callPackage,
  symlinkJoin,
  getopt,
  openfpgaloader,
  pkgsCross,
  prjxray-tools,
  prjxray-db,
  vtr,
  yosys,
  yosys-symbiflow,
  yosys-synlig,
  python3Packages,
}:
let
  install-xc7 = callPackage ./f4pga-arch-defs.nix {
    pkg = "install-xc7";
    hash = "sha256-j6GqnPwDPJ/vWcKsGdT/GFaKZryM4Vwzhc2ewdGQEnQ=";
  };
  xc7a50t_test = callPackage ./f4pga-arch-defs.nix {
    pkg = "xc7a50t_test";
    hash = "sha256-gZ6dVMkYKGlWIBREv3i0gq6UsyAukAw99ZPQEsFY108=";
  };
  xc7a100t_test = callPackage ./f4pga-arch-defs.nix {
    pkg = "xc7a100t_test";
    hash = "sha256-SbNV6KRC5GZSx7CJwj3AINS6u4AJ2PRJTgnXLjey5e8=";
  };
  xc7a200t_test = callPackage ./f4pga-arch-defs.nix {
    pkg = "xc7a200t_test";
    hash = "sha256-dfZnaWSoaUXSrE8dKLERJ2TE5EZA6GJ1jTcuICOracc=";
  };
  xc7z010_test = callPackage ./f4pga-arch-defs.nix {
    pkg = "xc7z010_test";
    hash = "sha256-um953QtcSCPvPG6K/CuiNYNkElMYDs7CImaI4h194sE=";
  };

  # something's going wrong with compiling the tests (C++ version mismatch?) so
  # disable them for now
  design_introspection = yosys-symbiflow.design_introspection.overrideAttrs { doCheck = false; };
  yosys-symbiflow' = yosys-symbiflow.override {
    yosys-symbiflow = {
      inherit design_introspection;
    };
  };
  # same for sdc
  sdc = yosys-symbiflow'.sdc.overrideAttrs { doCheck = false; };
in
symlinkJoin {
  name = "f4pga";
  # based on https://github.com/chipsalliance/f4pga-examples/blob/main/xc7/environment.yml
  #
  # hmm the xilinx stuff should probably be optional
  #
  # although, f4pga sems to expect that everything's in a `FPGA_FAM` subdir so
  # maybe we should bake that in? Or have a derivation for each family and then
  # another outer thing which combines them to create the install dir?
  paths = [
    openfpgaloader
    prjxray-tools
    pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.cc
    pkgsCross.riscv64-embedded.pkgsBuildHost.gcc.bintools
    prjxray-db
    vtr
    yosys
    design_introspection
    yosys-symbiflow.fasm
    yosys-symbiflow.integrateinv
    yosys-symbiflow.params
    yosys-symbiflow.ql-iob
    # ql-qlf # broken
    sdc
    yosys-symbiflow'.xdc
    yosys-synlig
    getopt # one of the shell scripts doesn't like BSD getopt
    python3Packages.intervaltree
    python3Packages.junit-xml
    python3Packages.lxml
    python3Packages.numpy
    python3Packages.openpyxl
    python3Packages.ordered-set
    python3Packages.parse
    python3Packages.progressbar2
    python3Packages.pyjson5
    python3Packages.pytest
    python3Packages.pyyaml
    python3Packages.scipy
    python3Packages.simplejson
    python3Packages.sympy
    python3Packages.textx
    python3Packages.yapf
    python3Packages.fasm
    python3Packages.prjxray
    python3Packages.f4pga-xc-fasm
    python3Packages.python-constraint
    python3Packages.f4pga
  ];
}
