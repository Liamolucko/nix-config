# Config that's shared between all my systems.
{ pkgs, lib, ... }:
{
  imports = [ ./minimal.nix ];

  fonts.packages = [ pkgs.noto-fonts ];

  home-manager.users.liam = import ./home-shared.nix;
}
