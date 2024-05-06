{
  lib,
  callPackage,
  buildPythonPackage,
  buildEnv,
  symlinkJoin,
  fetchFromGitHub,
  python,
  setuptools,
  wheel,
  colorama,
  fasm,
  getopt,
  lxml,
  prjxray,
  prjxray-db,
  prjxray-tools,
  python-constraint,
  pytest,
  pyyaml,
  simplejson,
  vtr,
  xc-fasm,
  yosys,
  yosys-symbiflow,
  archDefs ? null,
}:
let
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
  yosys-with-plugins = symlinkJoin {
    name = "${yosys.name}-with-plugins";
    paths = [
      yosys
      design_introspection
      yosys-symbiflow.fasm
      yosys-symbiflow.params
      yosys-symbiflow.ql-iob
      # yosys-symbiflow.ql-qlf # broken
      sdc
      yosys-symbiflow'.xdc
    ];
  };

  archDefsPkg = callPackage ./f4pga-arch-defs.nix { };
in
(buildPythonPackage {
  pname = "f4pga";
  version = "8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga";
    # From https://f4pga.readthedocs.io/en/latest/development/changes.html#id1
    rev = "6b4976a028e8a8a3b78711b6471655d3bfe58ed7";
    hash = "sha256-hxmEUnGpr1fYXG0W1Jbc6wT2I8XLNueEy/NjpBYwOlA=";
    fetchSubmodules = true;
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [
    colorama
    fasm
    lxml
    prjxray
    python-constraint
    pyyaml
    # TODO: package https://github.com/antmicro/quicklogic-fasm (won't be needed for xilinx)
    # TODO: package sdf-timing (also quicklogic only)
    simplejson
  ];
  propagatedBuildInputs = [
    getopt
    prjxray-db
    prjxray-tools
    vtr
    xc-fasm # TODO: treat this as an application instead of a package
    yosys-with-plugins
  ];

  preConfigure = ''
    cd f4pga
  '';

  makeWrapperArgs =
    if archDefs != null then
      [
        "--set"
        "F4PGA_INSTALL_DIR"
        "${archDefsPkg.installDir archDefs}"
      ]
    else
      [ ];
  postFixup =
    let
      toPatch = [
        "utils/quicklogic/convert_compile_opts"
        "utils/quicklogic/create_lib"
        "utils/quicklogic/pp3/create_ioplace"
        "utils/quicklogic/pp3/create_place_constraints"
        "utils/quicklogic/pp3/eos-s3/iomux_config"
        "utils/quicklogic/pp3/fasm2bels"
        "utils/quicklogic/process_sdc_constraints"
        "utils/quicklogic/qlf_k4n8/create_ioplace"
        "utils/quicklogic/repacker/repack"
        "utils/quicklogic/yosys_fixup_cell_names"
        "utils/xc7/create_ioplace"
        "utils/xc7/create_place_constraints"
        "utils/xc7/fix_xc7_carry"
        "utils/yosys_split_inouts"
        "wrappers/sh/generate_constraints"
        "wrappers/sh/vpr_run"
        "wrappers/tcl/__main__"
      ];
      substituteArgs = builtins.concatLists (
        builtins.map (
          path:
          let
            components = builtins.split "/" path;
            filtered = builtins.filter (segment: builtins.isString segment && segment != "__main__") components;
            modulePath = builtins.concatStringsSep "." filtered;
          in
          [
            "--replace-quiet"
            "-m f4pga.${modulePath}"
            "${placeholder "out"}/bin/.f4pga-scripts/${path}.py"
            "--replace-quiet"
            "['-m', 'f4pga.${modulePath}']"
            "['${placeholder "out"}/bin/.f4pga-scripts/${path}.py']"
          ]
        ) toPatch
      );
      substituteArgsStr = builtins.concatStringsSep " " (builtins.map (x: "\"${x}\"") substituteArgs);
    in
    ''
      for path in ${toString toPatch}; do
        local newPath="$out"/bin/.f4pga-scripts/"$path".py
        mkdir -p "$(dirname "$newPath")"
        cp "$path".py "$newPath"
        patchPythonScript "$newPath"
      done

      substituteInPlace \
        $out/${python.sitePackages}/f4pga/{flows/platforms.yml,wrappers/sh/{__init__.py,**/*.sh},wrappers/tcl/*.tcl} \
        ${substituteArgsStr}
    '';

  # This misfires because of `click` showing up both as its own derivation and in
  # a Python env used by yosys: that Python env isn't going to add itself to
  # PYTHONPATH and so it doesn't matter.
  catchConflicts = false;

  meta = {
    description = "FOSS Flow For FPGA";
    homepage = "https://github.com/chipsalliance/f4pga";
    license = lib.licenses.asl20;
  };
})
// {
  archDefs = archDefsPkg;
}
