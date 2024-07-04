{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  vivado = pkgs.vivado.joinModules {
    name = "vivado";
    paths = [
      pkgs.vivado.base
      pkgs.vivado.artix7
    ];
  };
in
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.packages = [
    pkgs.caffeine-ng
    pkgs.firefox
    pkgs.trashy
    pkgs.usbutils
    vivado
    pkgs.zed-editor
  ];

  programs.ssh = {
    enable = true;
    extraConfig = "IdentityAgent ~/.1password/agent.sock";
  };
}
