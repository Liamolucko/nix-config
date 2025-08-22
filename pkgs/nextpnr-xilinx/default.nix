{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  cmake,
  eigen,
  git,
  llvmPackages,
  python312,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nextpnr-xilinx";
  version = "0.8.2-unstable-2025-06-06";

  src = fetchFromGitHub {
    owner = "openXC7";
    repo = "nextpnr-xilinx";
    rev = "724db28b41e68568690a5ea1dd9ce5082362bb91";
    hash = "sha256-ni613AiHumk93DiyK9K7XwAutZHO0N1rRvFxCOKe2fY=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch2 {
      name = "scopeinfo.patch";
      url = "https://github.com/YosysHQ/nextpnr/commit/d00fdc8f7a20fe0e34911bb0cecb42a876738712.diff?full_index=1";
      hash = "sha256-NE8M4vBr/sUZIj4xVp+MBJA5dt8xqklrxwYXsWOsWT8=";
    })
  ];

  nativeBuildInputs = [
    cmake
    git
  ];
  buildInputs = [
    eigen
    python312
    python312.pkgs.boost
  ]
  ++ (lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ]);

  cmakeFlags = [
    "-DCURRENT_GIT_VERSION=${lib.substring 0 7 finalAttrs.src.rev}"
    "-DARCH=xilinx"
    "-DBUILD_GUI=OFF"
    "-DBUILD_TESTS=OFF"
    "-DUSE_OPENMP=ON"
    "-Wno-deprecated"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp nextpnr-xilinx bbasm $out/bin/
    mkdir -p $out/share/nextpnr/external
    cp -rv ../xilinx/external/prjxray-db $out/share/nextpnr/external/
    cp -rv ../xilinx/external/nextpnr-xilinx-meta $out/share/nextpnr/external/
    cp -rv ../xilinx/python/ $out/share/nextpnr/python/
    cp ../xilinx/constids.inc $out/share/nextpnr
  '';

  meta = {
    description = "Place and route tool for FPGAs";
    homepage = "https://github.com/openXC7/nextpnr-xilinx";
    license = lib.licenses.isc;
    platforms = lib.platforms.all;
  };
})
