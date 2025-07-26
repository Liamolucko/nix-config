{
  lib,
  pkgsLinux,
  stdenv,
  fixDarwinDylibNames,
  sevVariant ? false,
}:
let
  c-bundle = pkgsLinux.callPackage ./c-bundle.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libkrunfw";
  inherit (c-bundle) version src;

  # postPatch = ''
  #   substituteInPlace Makefile \
  #   --replace-fail '$(KERNEL_C_BUNDLE): $(KERNEL_BINARY_$(GUESTARCH))' '$(KERNEL_C_BUNDLE):'
  # '';

  nativeBuildInputs = lib.optionals stdenv.isDarwin [ fixDarwinDylibNames ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "KERNEL_C_BUNDLE=${c-bundle}"
  ]
  ++ lib.optionals sevVariant [
    "SEV=1"
  ];

  # Fixes https://github.com/containers/libkrunfw/issues/55
  # NIX_CFLAGS_COMPILE = lib.optionalString stdenv.targetPlatform.isAarch64 "-march=armv8-a+crypto";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Dynamic library bundling the guest payload consumed by libkrun";
    homepage = "https://github.com/containers/libkrunfw";
    license = with licenses; [
      lgpl2Only
      lgpl21Only
    ];
    maintainers = with maintainers; [
      nickcao
      RossComputerGuy
    ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ]
    ++ lib.optionals (!sevVariant) [
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
