{ pkgs, ... }:
{
  home.packages = [ (pkgs.zed-editor.override { withGLES = true; }) ];
}
