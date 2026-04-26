{ pkgs, ... }:
let
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

  programs.fish.shellInit = ''
    # If SSH_AUTH_SOCK has already been set by SSH agent forwarding, leave it, since
    # the user probably can't easily interact with the 1Password password prompt
    # anyway in that case.
    if ! echo $SSH_AUTH_SOCK | grep -q "$HOME/.ssh/agent"
      set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
    end
  '';

  gtk.enable = true;
  gtk.cursorTheme.name = "Adwaita";
  gtk.iconTheme.name = "Adwaita";

  programs.ssh = {
    enable = true;
  };

  xdg.autostart.enable = true;
  xdg.autostart.entries = [
    _1password-autostart
    "${pkgs.solaar.src}/share/autostart/solaar.desktop"
  ];
}
