{
  lib,
  stdenv,
  requireFile,
  # The regular `jre` works fine, but I don't want to require downloading two
  # different JREs for xinstall and Vivado.
  temurin-jre-bin,
}:
let
  suffix = "1013_2256";
in
stdenv.mkDerivation rec {
  pname = "xinstall";
  version = "2023.2";
  src = requireFile rec {
    name = "FPGAs_AdaptiveSoCs_Unified_${version}_${suffix}_Lin64.bin";
    url = "https://www.xilinx.com/member/forms/download/xef.html?filename=${name}";
    hash = "sha256-n6ilMK18728mPzu41hLEBhPLMin8JE9CcC1NECuIgu4=";
  };

  unpackCmd = "$curSrc --noexec --keep";

  patches = [ ./xinstall.patch ];
  postPatch = ''
    substituteInPlace bin/setup-boot-loader.sh \
      --subst-var-by javaHome '${temurin-jre-bin}'
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
}
