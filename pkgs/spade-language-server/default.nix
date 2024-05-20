{
  lib,
  rustPlatform,
  fetchFromGitLab,
  stdenv,
  darwin,
}:
let
  spadeSrc = fetchFromGitLab {
    owner = "spade-lang";
    repo = "spade";
    rev = "899bf3b33697b952e14429811a9351ca80c3f2eb";
    hash = "sha256-bzcwz1XcihjPVuyjpRVNXgZdLxFE/+d8gDAE7LvQUBc=";
  };
in
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
  # Spade assumes it's being built in its monorepo; add some of the folders it
  # expects to the vendor dir to get it to work.
  postPatch = ''
    ln -s ${spadeSrc}/{stdlib,prelude} ../cargo-vendor-dir
  '';

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/Liamolucko/spade-language-server";
    license = licenses.eupl12;
    maintainers = with maintainers; [ ];
    mainProgram = "spade-language-server";
  };
}
