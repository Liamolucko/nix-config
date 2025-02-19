{
  lib,
  fetchFromGitHub,
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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = pname;
    rev = "muvm-${version}";
    hash = "sha256-h6OUpkKFBbh5hO3ku91Gvn3GD9FgtIjtoWEhSwf3vXA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-W3qdUhh4L0KSDeyjl+JjxLvgremf+/sWaR7KU/16FKY=";

  patches = [
    (replaceVars ./replace-udevd.patch {
      systemd-udevd = "${systemd}/lib/systemd/systemd-udevd";
    })
    ./replace-sysctl.patch
    ./run-passthru.patch
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
