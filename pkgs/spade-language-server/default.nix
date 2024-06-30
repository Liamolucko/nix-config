{
  lib,
  rustPlatform,
  fetchFromGitLab,
  stdenv,
  darwin,
  openssl,
  pkg-config,
}:
let
  spadeSrc = fetchFromGitLab {
    owner = "Liamolucko";
    repo = "spade";
    rev = "85e44f44d83e9a4a8604e7fe9244fcce1e8d1885";
    hash = "sha256-cQweIm64c0xfJHnyjbCxEgyuEwsJYmLZ/Ztp/oIGeW4=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "spade-language-server";
  version = "0-unstable-2024-05-19";

  src = fetchFromGitLab {
    owner = "Liamolucko";
    repo = "spade-language-server";
    rev = "16526103dbe77c3bab15a56e3fd4b242a27af7d9";
    hash = "sha256-GzYLwpiSok8y53wJHsqcyMJPQ5pnNdred9th+bOxfcM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "codespan-0.12.0" = "sha256-3F2006BR3hyhxcUTaQiOjzTEuRECKJKjIDyXonS/lrE=";
      "spade-0.8.0" = "sha256-ahHn1tjqXfUXe6z2T0OVycpAo5NYhmWQbiHs9Ia0RLw=";
      "swim-0.8.0" = "sha256-tbB07hFdWsCfDrk8YOdcW0IG584F3g9a0xlcYfgZIqk=";
    };
  };
  # Spade assumes it's being built in its monorepo; add some of the folders it
  # expects to the vendor dir to get it to work.
  postPatch = ''
    ln -s ${spadeSrc}/{stdlib,prelude} ../cargo-vendor-dir
  '';

  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
  buildInputs =
    lib.optionals stdenv.isLinux [ openssl ]
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/Liamolucko/spade-language-server";
    license = licenses.eupl12;
    maintainers = with maintainers; [ ];
    mainProgram = "spade-language-server";
  };
}
