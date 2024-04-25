{
  stdenv,
  fetchFromGitHub,
  runCommand,
  llvmPackages_15,
  symlinkJoin,
  cmake,
  ninja,
  python3,
}:
let
  pname = "llvm-mctoll";
  version = "7f71a898fbffb0229d45b8115c62784f5cd9558e";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = pname;
    rev = version;
    hash = "sha256-po7refZb44czDt9lrZtC1YoWsj2okM4FVtz4ziQwERw=";
  };
  mounted-src = runCommand "mounted-src" { } ''
    mkdir -p $out/llvm/tools
    ln -s ${src} $out/llvm/tools/llvm-mctoll
  '';
in
stdenv.mkDerivation rec {
  inherit pname version;
  src = symlinkJoin {
    name = "${pname}-src-${version}";
    paths = [
      llvmPackages_15.libllvm.passthru.monorepoSrc
      mounted-src
    ];
  };
  sourceRoot = "${src.name}/llvm";

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=X86;ARM"
    "-DLLVM_ENABLE_PROJECTS=clang;lld"
    "-DLLVM_ENABLE_ASSERTIONS=true"
    "-DCLANG_DEFAULT_PIE_ON_LINUX=OFF"
  ];
  ninjaFlags = [ pname ];
}
