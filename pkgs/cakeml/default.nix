let
  cakemlArch =
    platform:
    if platform.isArmv7 then
      "arm7"
    else if platform.isAarch64 then
      "arm8"
    else if platform.isMips64 then
      "mips" # TODO: is this actually o64, or is it n32 / n64?
    else if platform.isRiscV64 then
      "riscv"
    else if platform.isx86_64 then
      "x64"
    else
      throw "Unsupported architecture";
in
{
  lib,
  pkgsx86_64Linux,
  callPackage,
  stdenv,
  asm ? pkgsx86_64Linux.callPackage ./stage-1.nix {
    arch = cakemlArch stdenv.hostPlatform;
    bits = if stdenv.targetPlatform.is64bit then "64" else "32";
  },
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cakeml";
  inherit (asm) version;
  src = asm;

  buildPhase = ''
    runHook preBuild

    "$CC" -O2 -o cake cake.S basis_ffi.c -lm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp cake "$out/bin"

    runHook postInstall
  '';

  passthru.asm = lib.listToAttrs (
    lib.concatMap
      (
        arch:
        lib.map
          (bits: {
            name = "${arch}-${bits}";
            value = callPackage ./stage-1.nix { inherit arch bits; };
          })
          [
            "32"
            "64"
          ]
      )
      [
        "ag32"
        "arm7"
        "arm8"
        "mips"
        "riscv"
        "x64"
      ]
  );

  meta = {
    description = "Verified implementation of ML";
    homepage = "https://cakeml.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Liamolucko ];
    mainProgram = "cake";
    platforms =
      lib.platforms.armv7
      ++ lib.platforms.aarch64
      ++ [
        "mips64-linux"
        "mips64el-linux"
      ]
      ++ lib.platforms.riscv64
      ++ lib.platforms.x86_64;
  };
})
