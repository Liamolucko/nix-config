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

  cargoHash = "sha256-hFJ6cImLPpHlGqgYmWiGEZw4ZuS8Di3r/O09w6Evj7U=";

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
