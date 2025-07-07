{
  stdenv,
  fetchFromGitHub,
  hol,
  arch,
  bits,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cakeml-stage-0";
  version = "2882";

  src = fetchFromGitHub {
    owner = "CakeML";
    repo = "cakeml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fKXUQcwgzlmJI76VRgB6kxuYAtNWP6z/6GvfB5Ljp6A=";
  };

  nativeBuildInputs = [ (hol.override { experimentalKernel = false; }) ];

  buildPhase = ''
    runHook preBuild

    cd compiler/bootstrap/compilation/${arch}/${bits}
    Holmake cake-${arch}-${bits}.tar.gz -j "$NIX_BUILD_CORES"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp cake-${arch}-${bits}.tar.gz "$out"

    runHook postInstall
  '';
})
