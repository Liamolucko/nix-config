{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  colorama,
  fasm,
  lxml,
  prjxray,
  python-constraint,
  pyyaml,
  simplejson,
}:
let
  selfPython = "${python.withPackages (p: [ (placeholder "out") ])}/bin/python";
in
buildPythonPackage {
  pname = "f4pga";
  version = "8";

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "f4pga";
    # From https://f4pga.readthedocs.io/en/latest/development/changes.html#id1
    rev = "6b4976a028e8a8a3b78711b6471655d3bfe58ed7";
    hash = "sha256-hxmEUnGpr1fYXG0W1Jbc6wT2I8XLNueEy/NjpBYwOlA=";
    fetchSubmodules = true;
  };

  pyproject = true;
  build-system = [ setuptools ];
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

  preConfigure = ''
    cd f4pga
  '';
  # TODO: decide whether we want to do another whack-a-mole thingy like this for yosys, prjxray-tools, etc. or just use wrapProgram and add them to PATH.
  # If we go the PATH route, this should just use PYTHONPATH as well
  # actually wait, I see literally 0 benefit in us holding out right now...
  # no wait, the benefit is that if we call into other python binaries they don't get to use our deps implicitly.
  # but we're already doing PATH stuff so yeah there's no reason to whack-a-mole with yosys and co.
  # (and no, there's no way to split the PATH stuff from the (not) PYTHONPATH embedding)
  # UGH ok so it turns out that `python.withPackages` isn't just a shell-hook thingy, it does actually work and I think that'd be a better way of doing this.
  # I jumped to conclusions when I saw that it was a binary file but it seems like it's some kind of binary wrapper.
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
      substituteArgsStr = builtins.concatStringsSep " " (builtins.map (x: "'${x}'") (substituteArgs));
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

  meta = {
    description = "FOSS Flow For FPGA";
    homepage = "https://github.com/chipsalliance/f4pga";
    license = lib.licenses.asl20;
  };
}
