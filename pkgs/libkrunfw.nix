{
  lib,
  stdenv,
  pkgsLinux,
  libkrunfw,
  sevVariant ? false,
}:
let
  c-bundle = pkgsLinux.libkrunfw.overrideAttrs (old: {
    postPatch =
      old.postPatch
      + ''
        substituteInPlace config-libkrunfw_aarch64 \
          --replace-warn 'CONFIG_CRYPTO_AEGIS128_SIMD=y' 'CONFIG_CRYPTO_AEGIS128_SIMD=n'
      '';
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ lib.optionals stdenv.isAarch64 [
        pkgsLinux.cpio
        pkgsLinux.perl
      ];
    # TODO skip actually compiling the .so
    # makeFlags = ["kernel.c"];?
    installPhase = ''
      runHook preInstall
      cp kernel.c $out
      runHook postInstall
    '';
  });
in
libkrunfw.overrideAttrs (old: {
  buildInputs = [ ];
  postPatch =
    old.postPatch
    + ''
      cp ${c-bundle} kernel.c
    '';
})
