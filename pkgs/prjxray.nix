{
  lib,
  buildPythonPackage,
  prjxray-tools,
  pythonPackages,
  fasm,
  intervaltree,
  numpy,
  pyjson5,
  pyyaml,
  simplejson,
}:
buildPythonPackage {
  pname = "prjxray";
  # Unlike prjxray-tools, plain prjxray doesn't have Anaconda releases we can get
  # version numbers from; so just copy them from prjxray-tools.
  inherit (prjxray-tools) version src meta;

  pyproject = true;
  dependencies = [
    fasm
    intervaltree
    numpy
    pyjson5
    pyyaml
    simplejson
  ];

  # The tests rely on litex which I don't want to package just for this.
  doCheck = false;

  # Remove broken fasm2frames
  postFixup = ''
    rm -rf $out/bin
  '';
}
