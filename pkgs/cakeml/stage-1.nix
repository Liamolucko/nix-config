{
  lib,
  callPackage,
  stdenv,
  cakeml,
  arch,
  bits,
}:
let
  stage-0 = callPackage ./stage-0.nix {
    # x64-64 is the only variant which includes cake-sexpr-*.
    arch = "x64";
    bits = "64";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cakeml-stage-1";
  inherit (stage-0) version;

  src = stage-0;

  nativeBuildInputs = [ (cakeml.override { asm = stage-0; }) ];

  buildPhase = ''
    runHook preBuild

    CML_STACK_SIZE=1000 CML_HEAP_SIZE=6000 cake --sexp=true --exclude_prelude=true --skip_type_inference=true --target=${arch} --reg_alg=0 < cake-sexpr-${bits} > cake.S

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir "$out"
    cp cake.S basis_ffi.c "$out"

    runHook postInstall
  '';

  meta = {
    inherit (stage-0.meta) sourceProvenance;
    platforms = lib.platforms.x86_64;
  };
})
