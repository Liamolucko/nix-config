{
  lib,
  pkgsCross,
  llvmPackages_17,
  substituteAll,
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
let
  libclang = python3.pkgs.libclang.override { llvmPackages = llvmPackages_17; };
in
llvmPackages_17.stdenv.mkDerivation rec {
  pname = "fex";
  version = "2408";
  src = fetchFromGitHub {
    owner = "FEX-Emu";
    repo = "FEX";
    rev = "FEX-${version}";
    hash = "sha256-6V9LDZm1dxm301JBjfk7+9J+QbkvMLMRZW9Tzip4LwM=";
    fetchSubmodules = true;
  };

  patches =
    [
      ./check-home.patch
      ./realpath.patch
    ]
    ++ lib.optionals doCheck [
      (substituteAll {
        src = ./cross-includes.patch;
        # These versions of glibc are the versions used by `stdenv.cc`, meaning that
        # they're already in the binary cache as a result of Hydra building it.
        i686Libs = pkgsCross.gnu32.stdenv.cc.libc_dev;
        x86_64Libs = pkgsCross.gnu64.stdenv.cc.libc_dev;
      })
    ];

  nativeBuildInputs = [
    cmake
    gitMinimal
    llvmPackages_17.bintools # for lld
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
  ];

  doCheck = true;
  nativeCheckInputs = [
    nasm
    libclang
  ];
  preCheck = ''
    patchelf \
      --set-interpreter ${pkgsCross.gnu64.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 \
      $(find ../External/{fex-posixtest-bins/conformance,fex-gvisor-tests-bins,fex-gcc-target-tests-bins/64} -type f -executable)
    patchelf \
      --add-rpath ${pkgsCross.gnu64.gcc.cc.lib}/lib \
      $(find ../External/fex-gvisor-tests-bins -type f -executable)
    patchelf \
      --set-interpreter ${pkgsCross.gnu32.stdenv.cc.libc}/lib/ld-linux.so.2 \
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

    # For some reason this test fails in darwin.linux-builder, and passes in a UTM
    # VM; paper over the difference by disabling it.
    echo 'write_test' >> ../unittests/gvisor-tests/Disabled_Tests
  '';

  meta = {
    description = "Fast usermode x86 and x86-64 emulator for Arm64 Linux";
    homepage = "https://fex-emu.com";
    license = lib.licenses.mit;
  };
}
