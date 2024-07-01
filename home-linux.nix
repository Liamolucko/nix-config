{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.packages = [
    pkgs.caffeine-ng
    pkgs.firefox
    pkgs.trashy
    pkgs.usbutils
    pkgs.zed-editor
  ];

  programs.ssh = {
    enable = true;
    extraConfig = "IdentityAgent ~/.1password/agent.sock";
  };
}
