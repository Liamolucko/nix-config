{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  graphviz,
  liberation_ttf,
  makeFontsConf,
  mlton,
  polyml,
  # TODO: this breaks bootstrapTheory and will need to be turned off for cakeml
  experimentalKernel ? true,
}:

let
  kernelFlag = if experimentalKernel then "--expk" else "--stdknl";
  buildSys = stdenv.buildPlatform.system;
  hostSys = stdenv.hostPlatform.system;
  # the current version of mlton doesn't support i686-linux
  # it also fails to build with musl
  useMlton =
    buildSys != "i686-linux"
    && hostSys != "i686-linux"
    && !stdenv.buildPlatform.isMusl
    && !stdenv.hostPlatform.isMusl
    && lib.elem buildSys mlton.meta.platforms
    && lib.elem hostSys mlton.meta.platforms;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "hol4";
  version = "trindemossen-1-unstable-2025-06-24";

  src = fetchFromGitHub {
    owner = "HOL-Theorem-Prover";
    repo = "HOL";
    rev = "718b3aaabc70079271693d5540ba16669c2e7ad2";
    hash = "sha256-L2gcWWHUat4lXRqwfMbJTCZMYaGWKY66N51yrUVX068=";
  };

  patches = [ ./no-abs-paths.patch ];

  buildInputs = [
    polyml
    graphviz
    fontconfig
  ] ++ lib.optional useMlton mlton;

  env.FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ liberation_ttf ];
    impureFontDirectories = [ ];
    includes = [ ];
  };

  enableParallelBuilding = true;

  configurePhase = ''
    mkdir -p "$out/src"
    cp -a . "$out/src"
    cd "$out/src"

    poly < tools/smart-configure.sml
  '';

  buildPhase = ''
    patchShebangs --build .

    jobs=''${enableParallelBuilding:+$NIX_BUILD_CORES}

    # We set -t3 for two reasons: because we want to run tests, and because setting
    # it builds many of HOL's examples, some of which are used by projects that
    # depend on HOL. Ordinarily, it's expected that the HOL repository is mutable,
    # and these examples can be built upon request; but this isn't the case with
    # Nix, so we need to build them ahead of time.
    bin/build ${kernelFlag} -j ''${jobs:-1} -t3
    # Some of Holmake's metadata (.HOLMK/*Theory.sml.d) only gets created the second
    # time it's run; run it again and create all of that metadata now before this
    # becomes an immutable Nix store path and it's too late.
    bin/build ${kernelFlag} -j ''${jobs:-1} -t3
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    ln -st "$out/bin" "$out"/src/bin/*
  '';

  meta = with lib; {
    description = "Interactive theorem prover based on Higher-Order Logic";
    longDescription = ''
      HOL4 is the latest version of the HOL interactive proof
      assistant for higher order logic: a programming environment in
      which theorems can be proved and proof tools
      implemented. Built-in decision procedures and theorem provers
      can automatically establish many simple theorems (users may have
      to prove the hard theorems themselves!) An oracle mechanism
      gives access to external programs such as SMT and BDD
      engines. HOL4 is particularly suitable as a platform for
      implementing combinations of deduction, execution and property
      checking.
    '';
    homepage = "https://hol-theorem-prover.org/";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mudri ];
  };
})
