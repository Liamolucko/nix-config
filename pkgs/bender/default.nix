{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "bender";
  version = "0.28.1";

  src = fetchFromGitHub {
    owner = "pulp-platform";
    repo = "bender";
    rev = "v${version}";
    hash = "sha256-eC4BY3ri73vgEtcXoPQ5NDknjZcPrKOzLo2vXWj4Adg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-fV4pWSRNlXCdnpeDgg3QW8s1Ixd1LEY8qP/Pb4t5xdc=";

  meta = {
    description = "A dependency management tool for hardware projects";
    homepage = "https://github.com/pulp-platform/bender";
    changelog = "https://github.com/pulp-platform/bender/blob/${src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "bender";
  };
}
