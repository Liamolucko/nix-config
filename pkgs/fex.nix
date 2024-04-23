{
  llvmPackages,
  fetchFromGitHub,
  git,
  cmake,
  ninja,
  pkg-config,
  SDL2,
  libepoxy,
  python3,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "fex";
  version = "2404";
  src = fetchFromGitHub {
    owner = "FEX-Emu";
    repo = "FEX";
    rev = "FEX-${version}";
    hash = "sha256-4BkU+8OTdeBJWHbCHJytD6rloN/p4M+k0zDlhNNBZjk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    git
    cmake
    ninja
    pkg-config
    llvmPackages.bintools # for lld
    (python3.withPackages (ps: [ ps.setuptools ]))
  ];
  buildInputs = [
    SDL2
    libepoxy
  ];

  cmakeFlags = [
    "-DUSE_LINKER=lld"
    # These 3 are optional.
    "-DENABLE_LTO=True"
    "-DBUILD_TESTS=False"
    "-DENABLE_ASSERTIONS=False"
    "-DCMAKE_C_COMPILER_AR=${llvmPackages.stdenv.cc}/bin/ar"
    "-DCMAKE_C_COMPILER_RANLIB=${llvmPackages.stdenv.cc}/bin/ranlib"
    "-DCMAKE_CXX_COMPILER_AR=${llvmPackages.stdenv.cc}/bin/ar"
    "-DCMAKE_CXX_COMPILER_RANLIB=${llvmPackages.stdenv.cc}/bin/ranlib"
  ];
}
