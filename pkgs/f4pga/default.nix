# TODO:
# - try enabling PGO for VTR
# - quicklogic support
{
  lib,
  buildPythonPackage,
  symlinkJoin,
  fetchFromGitHub,
  python,
  setuptools,
  wheel,
  colorama,
  fasm,
  getopt,
  lxml,
  makeBinaryWrapper,
  prjxray,
  prjxray-db,
  prjxray-tools,
  pytestCheckHook,
  python-constraint,
  pyyaml,
  simplejson,
  vtr,
  xc-fasm,
  yosys,
  yosys-symbiflow,
  installDir ? null,
}:
let
  yosysWithPlugins = symlinkJoin {
    name = "${yosys.name}-with-plugins";
    paths = [
      yosys
      yosys-symbiflow.design_introspection
      yosys-symbiflow.fasm
      yosys-symbiflow.params
      yosys-symbiflow.ql-iob
      # yosys-symbiflow.ql-qlf # broken
      yosys-symbiflow.sdc
      yosys-symbiflow.xdc
    ];
    # When the yosys binary is a symlink, it runs into an issue on Linux where the
    # xdc plugin ends up looking in the original yosys derivation instead of the
    # joined one for some of its data, and can't find it. So copy it and make sure
    # there's no symlink to be accidentally resolved in the first place.
    #
    # The only reason it can load the plugin itself seems to be because of some
    # Yosys's setup hook; if you bake in the path to Yosys directly rather than
    # using `nativeBuildInputs`, it can't load the plugin either.
    postBuild = ''
      real_yosys=$(realpath $out/bin/yosys)
      rm $out/bin/yosys
      cp $real_yosys $out/bin/yosys
    '';
  };

  self = buildPythonPackage {
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

    patches = [
      ./no-path.patch
      ./params-without-values.patch # TODO upstream
    ];

    nativeBuildInputs = [ makeBinaryWrapper ];

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

    postPatch = ''
      substituteInPlace \
        f4pga/flows/{commands.py,common.py,platforms.yml} \
        f4pga/flows/common_modules/{fasm,place_constraints,synth}.py \
        f4pga/utils/xc7/create_place_constraints.py \
        f4pga/wrappers/sh/__init__.py \
        f4pga/wrappers/sh/quicklogic/{ql,synth}.f4pga.sh \
        f4pga/wrappers/sh/xc7/synth.f4pga.sh \
        --subst-var-by wrappedPython $out/bin/.f4pga-python \
        --subst-var-by getopt ${getopt}/bin/getopt \
        --subst-var-by prjxray-db ${prjxray-db} \
        --subst-var-by xc7frames2bit ${prjxray-tools}/bin/xc7frames2bit \
        --subst-var-by vtr ${vtr} \
        --subst-var-by xcfasm ${xc-fasm}/bin/xcfasm \
        --subst-var-by yosys ${yosysWithPlugins}/bin/yosys
    '';

    preConfigure = ''
      cd f4pga
    '';

    # TODO: this doesn't work if you use it as a library.
    #
    # I guess we could patch instead? There's only one centralised place that sets
    # it (context.py) so it'd be easy.
    makeWrapperArgs = lib.optionals (installDir != null) [
      "--set"
      "F4PGA_INSTALL_DIR"
      installDir
    ];

    postFixup =
      let
        pythonPath = lib.makeSearchPath python.sitePackages (
          [ (placeholder "out") ] ++ self.requiredPythonModules
        );
      in
      ''
        # Based on https://github.com/NixOS/nixpkgs/blob/b4d7dd85b54def064726d1668917f2265023305d/pkgs/development/interpreters/python/wrapper.nix#L45.
        #
        # TODO: does it matter that we don't set NIX_PYTHONPREFIX here?
        makeWrapper ${python.interpreter} $out/bin/.f4pga-python \
          --set NIX_PYTHONEXECUTABLE ${python}/bin/python \
          --set NIX_PYTHONPATH '${pythonPath}' \
          --set PYTHONNOUSERSITE "true"
      '';

    nativeCheckInputs = [ pytestCheckHook ];
    # There are some other tests sitting around in the repo which weren't updated
    # after being moved here from the f4pga-arch-defs repo, and don't work anymore.
    # So we have to only run the tests in the test/ directory, the same as CI does.
    pytestFlagsArray = [ "../test/" ];

    meta = {
      description = "FOSS Flow For FPGA";
      homepage = "https://github.com/chipsalliance/f4pga";
      license = lib.licenses.asl20;
    };
  };
in
self
