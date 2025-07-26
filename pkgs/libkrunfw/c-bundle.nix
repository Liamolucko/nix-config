{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  flex,
  bison,
  bc,
  cpio,
  perl,
  elfutils,
  python3,
  sevVariant ? false,
}:
let
  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v6.x/linux-6.6.59.tar.xz";
    hash = "sha256-I2FoCNjAjxKBX/iY9O20wROXorKEPQKe5iRS0hgzp20=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libkrunfw-c-bundle";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libkrunfw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GFfBiGMOyBwMKjpD1kj3vRpvjR0ydji3QNDyoOQoQsw=";
  };

  nativeBuildInputs = [
    flex
    bison
    bc
    cpio
    perl
    python3
    python3.pkgs.pyelftools
  ];

  buildInputs = [
    elfutils
  ];

  makeFlags = [
    "KERNEL_TARBALL=${kernelSrc}"
    "kernel.c"
  ]
  ++ lib.optionals sevVariant [
    "SEV=1"
  ];

  installPhase = ''
    runHook preInstall
    cp kernel.c "$out"
    runHook postInstall
  '';

  # Fixes https://github.com/containers/libkrunfw/issues/55
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.targetPlatform.isAarch64 "-march=armv8-a+crypto";

  enableParallelBuilding = true;
})
