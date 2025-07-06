{
  lib,
  stdenv,
  fetchurl,
}:
let
  hashes = {
    arm8-64 = "sha256-DCUOa6wXS09VBxTKOwXyyE005zAw+YQ6y/FibuV8IhY=";
    x64-32 = "sha256-SHR9Dw5PC3NBg7i6imAnXIMs/pK8g76BYQ/y1xjCdaY=";
    x64-64 = "sha256-WYJ0Noj0lEpMeae85pLo99MDlCzes2FVA1VZx02szqU=";
  };

  arch =
    if stdenv.targetPlatform.isAarch then
      "arm8"
    else if stdenv.targetPlatform.isx86 then
      "x64"
    else
      throw "Unsupported architecture";
  bits = if stdenv.targetPlatform.is64bit then "64" else "32";
  target = "${arch}-${bits}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cakeml";
  version = "2882";

  src = fetchurl {
    url = "https://github.com/CakeML/cakeml/releases/download/v${finalAttrs.version}/cake-${target}.tar.gz";
    hash = hashes.${target};
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp cake "$out/bin"

    runHook postInstall
  '';

  meta = {
    description = "Verified implementation of ML";
    homepage = "https://github.com/CakeML/cakeml";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Liamolucko ];
    mainProgram = "cakeml";
    platforms = lib.platforms.all;
  };
})
