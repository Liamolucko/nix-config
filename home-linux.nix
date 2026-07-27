{
  lib,
  pkgs,
  ...
}:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
  _1password-autostart = pkgs.runCommand "1password-autostart" { } ''
    cp '${pkgs._1password-gui}/share/applications/1password.desktop' "$out"
    substituteInPlace "$out" --replace-fail "1password %U" "1password --silent"
  '';
in
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  sshAuthSock = {
    enable = true;
    initialization.bash = "export SSH_AUTH_SOCK=$HOME/.1password/agent.sock";
    initialization.fish = "set -x SSH_AUTH_SOCK $HOME/.1password/agent.sock";
    # for some reason this option is required... this might work?
    systemd.socketProviderUnit = "app-1password@autostart.service";
  };

  gtk.enable = true;
  gtk.cursorTheme.name = "Adwaita";
  gtk.iconTheme.name = "Adwaita";

  xdg.autostart.enable = true;
  xdg.autostart.entries = [
    "${pkgs.solaar.src}/share/autostart/solaar.desktop"
  ]
  ++ lib.optionals (!ciSafe) [ _1password-autostart ];
}
