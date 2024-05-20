{
  lib,
  rustPlatform,
  fetchFromGitLab,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "spade-language-server";
  version = "unstable-2024-05-19";

  src = fetchFromGitLab {
    owner = "Liamolucko";
    repo = "spade-language-server";
    rev = "3c56462d555143c9beb5522d6c3a5f1781c95945";
    hash = "sha256-241YKeVUAYCDC6w3vdkU4WubJ820jvoG4FYcUJXYTD4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "codespan-0.12.0" = "sha256-3F2006BR3hyhxcUTaQiOjzTEuRECKJKjIDyXonS/lrE=";
      "spade-0.8.0" = "sha256-pu/h/XBcLa+wJvZ7L+g9tKIwIdaG2TyVFhKmRmz9TA0=";
      "swim-0.8.0" = "sha256-tbB07hFdWsCfDrk8YOdcW0IG584F3g9a0xlcYfgZIqk=";
    };
  };

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/Liamolucko/spade-language-server";
    license = licenses.eupl12;
    maintainers = with maintainers; [ ];
    mainProgram = "spade-language-server";
  };
}
