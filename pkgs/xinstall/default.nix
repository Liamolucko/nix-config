{
  lib,
  stdenv,
  requireFile,
  # The regular `jre` works fine, but I don't want to require downloading two
  # different JREs for xinstall and Vivado.
  temurin-jre-bin-21,
}:
let
  suffix = "0522_2023";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xinstall";
  version = "2024.1";
  src = requireFile rec {
    name = "FPGAs_AdaptiveSoCs_Unified_${finalAttrs.version}_${suffix}_Lin64.bin";
    url = "https://www.xilinx.com/member/forms/download/xef.html?filename=${name}";
    hash = "sha256-mgStIGvg2a/Z0RzXmXtOaXhIXu5E9H1MCNB9vDDLLx4=";
  };

  unpackCmd = "sh $curSrc --noexec --keep";

  patches = [ ./xinstall.patch ];
  postPatch = ''
    substituteInPlace bin/setup-boot-loader.sh \
      --subst-var-by javaHome '${temurin-jre-bin-21}'
    rm -rf tps
  '';

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  meta = {
    description = "Web installer for AMD adaptive SoC and FPGA design software";
    homepage = "https://www.xilinx.com/support/download.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
