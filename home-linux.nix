{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  digilent-board-files = pkgs.fetchFromGitHub {
    owner = "Digilent";
    repo = "vivado-boards";
    rev = "8ed4f9981da1d80badb0b1f65e250b2dbf7a564d";
    hash = "sha256-yb0Z4+1at3U7ZnH9Db3siHTBIMV4bHUaTu/y3dq+Y0k=";
  };
  vivado = pkgs.vivado.override {
    modules = [
      "Artix-7"
      "DocNav"
    ];
    extraPaths = [
      (pkgs.runCommand "digilent-board-files" { } ''
        mkdir -p $out/Vivado/${pkgs.vivado.version}/data/boards
        cp -r ${digilent-board-files}/new/board_files $out/Vivado/${pkgs.vivado.version}/data/boards/board_files
      '')
    ];
  };
in
{
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  home.packages = [
    pkgs.caffeine-ng
    pkgs.firefox
    pkgs.usbutils
    vivado
    pkgs.zed-editor
  ];

  programs.ssh = {
    enable = true;
    extraConfig = "IdentityAgent ~/.1password/agent.sock";
  };
}
