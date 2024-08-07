{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  setuptools,
  wheel,
  litedram,
  liteeth,
  litepcie,
  litesata,
  litescope,
  litesdcard,
  litespi,
  litex,
  pythondata-cpu-vexriscv,
  pythondata-misc-usb-ohci,
  pythondata-software-compiler-rt,
  pythondata-software-picolibc,
  terminus_font,
  unittestCheckHook,
}:
let
  terminus-font-src = stdenv.mkDerivation {
    pname = "terminus-font-src";
    inherit (terminus_font) version src meta;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';
  };
  litehyperbus = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litehyperbus";
    rev = "2022.04";
    hash = "sha256-XbguKDtA8fo7kWEQFUA2DAj2Z7yHRkKsaSR2h7igM4g=";
  };
in
buildPythonPackage rec {
  pname = "litex-boards";
  version = "2024.04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "litex-hub";
    repo = "litex-boards";
    rev = version;
    hash = "sha256-pHtVotOZDZKE4RGUIn2rZTCPBjpLiEJLuLyaOcDCQbg=";
  };

  build-system = [
    setuptools
    wheel
  ];
  dependencies = [ litex ];

  nativeCheckInputs = [
    litedram
    liteeth
    litepcie
    litesata
    litescope
    litesdcard
    litespi
    pythondata-cpu-vexriscv
    pythondata-misc-usb-ohci
    pythondata-software-compiler-rt
    pythondata-software-picolibc
    unittestCheckHook
    # I'm not packaging valentyusb right now because it's a bit dodgy: LiteX uses a
    # fork of it, and I don't want to pretend it's official by naming it an
    # unprefixed `valentyusb`.
  ];
  # TODO: should the ter-u16b fix go in litex itself?
  preCheck = ''
    # Stop LiteX trying to `wget` these.
    cp ${terminus-font-src}/ter-u16b.bdf .
    cp ${litehyperbus}/litehyperbus/core/hyperbus.py .

    # Remove stuff that depends on valentyusb for now.
    # This happens after installation, so they'll still be in the output.
    rm litex_boards/targets/{gsd_orangecrab,kosagi_fomu,logicbone}.py
  '';

  meta = with lib; {
    description = "LiteX boards files";
    homepage = "https://github.com/litex-hub/litex-boards";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
