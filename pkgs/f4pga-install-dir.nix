{ callPackage, runCommand }:
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
# Note: we can't just use symlinkJoin for this because VTR can't handle leaf
# files being symlinks.
runCommand "f4pga-install-dir" { } ''
  mkdir -p $out/xc7/share/f4pga/{techmaps,arch}
  ln -s ${install-xc7}/share/f4pga/techmaps/xc7_vpr $out/xc7/share/f4pga/techmaps
  ln -s ${xc7a50t_test}/share/f4pga/arch/xc7a50t_test $out/xc7/share/f4pga/arch
  ln -s ${xc7a100t_test}/share/f4pga/arch/xc7a100t_test $out/xc7/share/f4pga/arch
  ln -s ${xc7a200t_test}/share/f4pga/arch/xc7a200t_test $out/xc7/share/f4pga/arch
  ln -s ${xc7z010_test}/share/f4pga/arch/xc7z010_test $out/xc7/share/f4pga/arch
''
