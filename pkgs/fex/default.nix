{
  lib,
  pkgsCross,
  llvmPackages,
  replaceVars,
  fetchFromGitHub,
  cmake,
  gitMinimal,
  nasm,
  ninja,
  pkg-config,
  python3,
  qt5,
}:
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "fex";
  version = "2412";
  src = fetchFromGitHub {
    owner = "FEX-Emu";
    repo = "FEX";
    rev = "FEX-${finalAttrs.version}";
    hash = "sha256-VwcfxdRMjE/yoe5q0p3j4FdEMOJdtq17moxiGWO+CN0=";
    fetchSubmodules = true;
  };

  patches =
    [
      # This is a workaround to get FEX working with NixOS's slightly weird binfmt
      # infrastructure.
      ./realpath.patch
    ]
    ++ lib.optionals finalAttrs.finalPackage.doCheck [
      (replaceVars ./cross-includes.patch {
        # These versions of glibc are the versions used by `stdenv.cc`, meaning that
        # they're already in the binary cache as a result of Hydra building it.
        i686Libs = pkgsCross.gnu32.stdenv.cc.libc_dev;
        x86_64Libs = pkgsCross.gnu64.stdenv.cc.libc_dev;
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
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtquickcontrols
    qt5.qtquickcontrols2
  ];

  cmakeFlags = [
    "-DUSE_LINKER=lld"
    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;
  nativeCheckInputs = [
    nasm
    python3.pkgs.libclang
  ];
  preCheck = ''
    find \
      ../External/fex-posixtest-bins/conformance \
      ../External/fex-gvisor-tests-bins \
      ../External/fex-gcc-target-tests-bins/64 \
      -type f -executable \
      -exec patchelf \
        --set-interpreter ${pkgsCross.gnu64.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 \
        '{}' '+'
    find ../External/fex-gcc-target-tests-bins/32 -type f -executable \
      -exec patchelf \
        --set-interpreter ${pkgsCross.gnu32.stdenv.cc.libc}/lib/ld-linux.so.2 \
        '{}' '+'

    find ../External/fex-gvisor-tests-bins -type f -executable \
      -exec patchelf --add-rpath ${pkgsCross.gnu64.stdenv.cc.cc.lib}/lib '{}' '+'

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

  # Avoid wrapping anything other than FEXConfig, since the wrapped executables
  # don't seem to work when registered as binfmts.
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp $out/bin/FEXConfig
  '';

  meta = {
    description = "Fast usermode x86 and x86-64 emulator for Arm64 Linux";
    homepage = "https://fex-emu.com";
    license = lib.licenses.mit;
  };
})
