{ pkgs, ... }:
let
  vivado = pkgs.vivado.override {
    modules = [
      "Artix-7"
      "DocNav"
    ];
    extraPaths = [ pkgs.digilent-board-files ];
  };
in
{
  home.packages = [
    vivado
    pkgs.zed-editor
  ];
}
