{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
}:
rustPlatform.buildRustPackage rec {
  pname = "calyx-lsp";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "calyxir";
    repo = "calyx";
    rev = "v${version}";
    hash = "sha256-JZl+8JT/gngZ2Vunz7w3vP/iv3qxSw4jh8/C4SSHNd8=";
  };
  buildAndTestSubdir = "calyx-lsp";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "dap-0.3.1-alpha1" = "sha256-yqY79gGVVnxJDKWtfcr7hYYDlX+3s5tKBxiddZA1NiU=";
    };
  };

  buildInputs = [ libiconv ];

  meta = {
    description = "Language server for Calyx";
    homepage = "https://docs.calyxir.org/tools/language-server.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    meta.mainProgram = "calyx-lsp";
  };
}
