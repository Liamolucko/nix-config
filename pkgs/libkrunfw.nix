{ pkgsLinux, libkrunfw }:
let
  c-bundle = pkgsLinux.libkrunfw.overrideAttrs {
    installPhase = ''
      cp kernel.c $out
    '';
  };
in
libkrunfw.overrideAttrs (old: {
  postPatch = old.postPatch ++ ''
    cp ${c-bundle} kernel.c
  '';
})
