{
  pkgs,
  lib,
  config,
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
      ProgramArguments = [ "${pkgs.maccy}/Applications/Maccy.app/Contents/MacOS/Maccy" ];
      KeepAlive = true;
    };
  };

  # launchd.agents.sage = {
  #   enable = true;
  #   config = {
  #     Label = "org.nixos.sage";
  #     ProgramArguments = [
  #       (lib.getExe pkgs.sage)
  #       "--notebook"
  #       "--no-browser"
  #       "--port=8888"
  #     ];
  #     WorkingDirectory = config.home.homeDirectory;
  #     KeepAlive = true;
  #   };
  # };

  launchd.agents.solaar = {
    enable = true;
    config = {
      # based on https://github.com/pwr-Solaar/Solaar/blob/master/tools/create-macos-launchagent.sh
      Label = "io.github.pwr-solaar.solaar";
      ProgramArguments = [
        (lib.getExe pkgs.solaar)
        "--window=hide"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/solaar.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/solaar.error.log";
      ProcessType = "Background";
    };
  };

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
