{ pkgs, ... }:
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.ssh = {
    enable = true;
    extraConfig = "IdentityAgent ~/.1password/agent.sock";
  };
}
