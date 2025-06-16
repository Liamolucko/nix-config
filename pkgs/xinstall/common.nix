{
  lib,
  callPackage,
  stdenv,
  requireFile,
  replaceVars,
  # The regular `jre` works fine, but I don't want to require downloading two
  # different JREs for xinstall and Vivado.
  temurin-jre-bin-21,
  meta,
}:
let
  patch =
    if lib.versionAtLeast meta.version "2025.1" then
      patches/xinstall-2025.1.patch
    else
      patches/xinstall-2024.1.patch;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xinstall";
  inherit (meta) version;
  src = requireFile rec {
    name = "${meta.name}_${meta.version}_${meta.suffix}_Lin64.bin";
    url = "https://www.xilinx.com/member/forms/download/xef.html?filename=${name}";
    hash = meta.webInstallerHash;
  };

  unpackCmd = "sh $curSrc --noexec --keep";

  patches = [
    (replaceVars patch {
      inherit (meta) jreVer;
      javaHome = temurin-jre-bin-21;
    })
  ];
  postPatch = ''
    rm -rf tps
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru = {
    run =
      args:
      callPackage ./run.nix (
        {
          xinstall = finalAttrs.finalPackage;
          inherit meta;
        }
        // args
      );
  };

  meta = {
    description = "Web installer for AMD adaptive SoC and FPGA design software";
    homepage = "https://www.xilinx.com/support/download.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
