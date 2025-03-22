{
  stdenv,
  fetchFromGitHub,
  yosys,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "eqy";
  version = "0.50";
  src = fetchFromGitHub {
    owner = "YosysHQ";
    repo = "eqy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wBBSHWjbg/9jq8btGEgRD2tlkf98uehe+kVgRbxjzes=";
  };

  # TODO: patch paths to yosys and other things in exe_paths; exe_paths also isn't being used in EqySatStrategy and main.
  # Ugh, and sby isn't even included in exe_paths...
  #
  # TODO: patch out /usr/bin/env so tests work in sandbox

  preBuild = ''
    substituteInPlace Makefile \
      --replace-fail '[os.path.dirname(__file__) + p for p in ["/share/python3", "/../share/yosys/python3"]]' \
      "[p + \"/share/yosys/python3\" for p in [\"$out\", \"${yosys}\"]]"
  '';
  buildInputs = [ yosys ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  # doInstallCheck = true;
  # preInstallCheck = ''
  #   export "PATH=$out/bin:$PATH"
  # '';
  # installCheckTarget = "test";
})
