{
  lib,
  rustPlatform,
  fetchFromGitLab,
  stdenv,
  darwin,
  gitMinimal,
}:

rustPlatform.buildRustPackage rec {
  pname = "swim";
  version = "0.8.0-unstable-2024-05-15";

  src = fetchFromGitLab {
    owner = "spade-lang";
    repo = "swim";
    rev = "89f3c1d6b8ec8d541c7621614a8e591cbe2b0ed0";
    hash = "sha256-tbB07hFdWsCfDrk8YOdcW0IG584F3g9a0xlcYfgZIqk=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-/Ma+ICaTXg1HnbsMqLwg3T6+tgu0s9ScDyHyhsdZhgU=";

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  nativeCheckInputs = [ gitMinimal ];
  checkFlags = [
    # These tests attempt to use `git clone`.
    "--skip=init::tests::init_board_correctly_sets_project_name"
    "--skip=init::tests::init_board_creates_required_files"
    "--skip=plugin::test::deny_changes_to_plugins::edits_are_denied"
    "--skip=plugin::test::deny_changes_to_plugins::restores_work"
    # For some reason this gives a 'no such file or directory' error while trying to
    # run `git init` even though it's there.
    "--skip=init::tests::git_init_then_swim_init_works"
  ];

  meta = with lib; {
    description = "A build tool for spade";
    homepage = "https://gitlab.com/spade-lang/swim";
    changelog = "https://gitlab.com/spade-lang/swim/-/blob/${src.rev}/CHANGELOG.md";
    license = licenses.eupl12;
    maintainers = with maintainers; [ ];
    mainProgram = "swim";
  };
}
