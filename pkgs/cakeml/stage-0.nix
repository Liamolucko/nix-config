{
  lib,
  fetchurl,
  arch,
  bits,
}:
let
  version = "2882";
  hashes = {
    arm8-64 = "sha256-DCUOa6wXS09VBxTKOwXyyE005zAw+YQ6y/FibuV8IhY=";
    x64-32 = "sha256-SHR9Dw5PC3NBg7i6imAnXIMs/pK8g76BYQ/y1xjCdaY=";
    x64-64 = "sha256-WYJ0Noj0lEpMeae85pLo99MDlCzes2FVA1VZx02szqU=";
  };
  variant = "${arch}-${bits}";
in
fetchurl {
  url = "https://github.com/CakeML/cakeml/releases/download/v${version}/cake-${variant}.tar.gz";
  hash = hashes.${variant};
  passthru.version = version;
  meta.sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
}
