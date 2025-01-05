{ ... }:
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  gtk.enable = true;
  gtk.cursorTheme.name = "Adwaita";
  gtk.iconTheme.name = "Adwaita";

  programs.ssh = {
    enable = true;
    extraConfig = "IdentityAgent ~/.1password/agent.sock";
  };
}
