{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.username = "liam";
  home.homeDirectory = "/Users/liam";

  launchd.agents.maccy = {
    enable = true;
    config = {
      Label = "org.nixos.maccy";
      Program = "${pkgs.maccy}/Applications/Maccy.app/Contents/MacOS/Maccy";
      KeepAlive = true;
    };
  };

  # TODO: add a launchd agent for rclone nfsmount

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
