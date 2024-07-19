{
  lib,
  pkgsCross,
  llvmPackages,
  substituteAll,
  symlinkJoin,
  writeTextFile,
  fetchFromGitHub,
  cmake,
  gitMinimal,
  libepoxy,
  nasm,
  ninja,
  pkg-config,
  python3,
  SDL2,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "fex";
  version = "2407";
  src = fetchFromGitHub {
    owner = "FEX-Emu";
    repo = "FEX";
    rev = "FEX-${version}";
    hash = "sha256-an7Cc3HsKxjnulOog9FqZZuvLNumyGH237hqN6ykzlU=";
    fetchSubmodules = true;
  };

  patches = lib.optionals doCheck [
    (substituteAll {
      src = ./cross-includes.patch;
      i686Libs = pkgsCross.gnu32.glibc.dev;
      x86_64Libs = pkgsCross.gnu64.glibc.dev;
      aarch64Libs = pkgsCross.aarch64-multiplatform.glibc.dev;
    })
  ];

  nativeBuildInputs = [
    cmake
    gitMinimal
    llvmPackages.bintools # for lld
    ninja
    pkg-config
    python3
    python3.pkgs.setuptools
  ];
  buildInputs = [
    libepoxy
    SDL2
  ];

  cmakeFlags = [
    "-DUSE_LINKER=lld"
    "-DBUILD_TESTS=${if doCheck then "True" else "False"}"
    "-DCMAKE_C_COMPILER_AR=${llvmPackages.stdenv.cc}/bin/ar"
    "-DCMAKE_C_COMPILER_RANLIB=${llvmPackages.stdenv.cc}/bin/ranlib"
    "-DCMAKE_CXX_COMPILER_AR=${llvmPackages.stdenv.cc}/bin/ar"
    "-DCMAKE_CXX_COMPILER_RANLIB=${llvmPackages.stdenv.cc}/bin/ranlib"
  ];

  doCheck = true;
  nativeCheckInputs = [
    nasm
    python3.pkgs.libclang
  ];
  preCheck = ''
    # Make FEXServer store its state in the working directory.
    export HOME=$PWD

    patchelf \
      --set-interpreter ${pkgsCross.gnu64.glibc}/lib/ld-linux-x86-64.so.2 \
      $(find ../External/{fex-posixtest-bins/conformance,fex-gvisor-tests-bins,fex-gcc-target-tests-bins/64} -type f -executable)
    patchelf \
      --add-rpath ${pkgsCross.gnu64.gcc.cc.lib}/lib \
      $(find ../External/fex-gvisor-tests-bins -type f -executable)
    patchelf \
      --set-interpreter ${pkgsCross.gnu32.glibc}/lib/ld-linux.so.2 \
      $(find ../External/fex-gcc-target-tests-bins/32 -type f -executable)

    # These all seem to fail due to the build sandbox.
    echo -n '
    conformance-interfaces-sched_setparam-26-1.test
    conformance-interfaces-sigqueue-12-1.test
    conformance-interfaces-sigqueue-3-1.test
    ' >> ../unittests/POSIX/Known_Failures

    echo -n '
    dev_test
    getcpu_host_test
    getcpu_test
    lseek_test
    tuntap_test
    write_test
    ' >> ../unittests/gvisor-tests/Known_Failures
  '';
}
