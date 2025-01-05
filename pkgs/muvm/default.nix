{
  lib,
  fetchFromGitHub,
  fetchpatch,
  rustPlatform,
  dhcpcd,
  libkrun,
  makeWrapper,
  passt,
  pkg-config,
  mesa,
  replaceVars,
  systemd,
  opengl-driver ? mesa.drivers,
}:

rustPlatform.buildRustPackage rec {
  pname = "muvm";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = pname;
    rev = "muvm-${version}";
    hash = "sha256-eB60LjI1Qr85MPtQh0Fb5ihzBahz95tXaozNe8q6o3o=";
  };

  cargoHash = "sha256-ilCVALy1ofiq6Ak8nBhWusPwRAnD9VgOiOV5PKhF5GQ=";

  patches = [
    (replaceVars ./replace-udevd.patch {
      systemd-udevd = "${systemd}/lib/systemd/systemd-udevd";
    })
    ./opengl-driver.patch
    ./replace-sleep.patch
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    (libkrun.override {
      withBlk = true;
      withGpu = true;
      withNet = true;
    })
    systemd
  ];

  # Allow for sommelier to be disabled as it can cause problems.
  wrapArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        passt
        dhcpcd
      ]
    }"
  ];

  postFixup = ''
    wrapProgram $out/bin/muvm $wrapArgs \
      --set-default OPENGL_DRIVER ${opengl-driver}
  '';

  meta = {
    description = "Run programs from your system in a microVM";
    homepage = "https://github.com/AsahiLinux/muvm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = libkrun.meta.platforms;
    mainProgram = "krun";
  };
}
