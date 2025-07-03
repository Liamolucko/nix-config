{
  buildPythonPackage,
  prjxray-tools,
  setuptools,
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
  build-system = [ setuptools ];
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

  # Replace the broken wrapper that tries to invoke fasm2frames via.
  # `utils.fasm2frames`, which doesn't get installed, with the original
  # fasm2frames script.
  postInstall = ''
    cp utils/fasm2frames.py $out/bin/fasm2frames
  '';
}
