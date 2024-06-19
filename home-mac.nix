{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.username = "liam";
  home.homeDirectory = "/Users/liam";

  home.packages = [
    pkgs.colima
    pkgs.darwin.trash
    pkgs.docker
    # Workaround for https://github.com/rustwasm/wasm-bindgen/issues/3646.
    # I've been doing this since long before that issue was opened though, I should
    # really go fix it at some point.
    pkgs.gnused
    # TODO add a launch agent for this
    pkgs.maccy
    pkgs.musescore
    pkgs.utm
  ];

  # TODO: add a launchd agent for rclone nfsmount

  programs.fish.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  programs.fish.loginShellInit = ''
    fish_add_path --move --prepend --path ${
      lib.concatMapStringsSep " " (profile: ''"${profile}/bin"'') osConfig.environment.profiles
    }
    set fish_user_paths $fish_user_paths
  '';

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
}
