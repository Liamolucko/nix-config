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
    pkgs.firefox
    pkgs.zed-editor
  ];
}
