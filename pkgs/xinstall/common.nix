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
stdenv.mkDerivation (finalAttrs: {
  pname = "xinstall";
  inherit (meta) version;
  src = requireFile rec {
    name = "FPGAs_AdaptiveSoCs_Unified_${meta.version}_${meta.suffix}_Lin64.bin";
    url = "https://www.xilinx.com/member/forms/download/xef.html?filename=${name}";
    hash = "sha256-mgStIGvg2a/Z0RzXmXtOaXhIXu5E9H1MCNB9vDDLLx4=";
  };

  unpackCmd = "sh $curSrc --noexec --keep";

  patches = [
    (replaceVars patches/xinstall.patch {
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
    inherit meta;
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
