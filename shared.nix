# Config that's shared between all my systems.
{ pkgs, ... }:
{
  imports = [ ./minimal.nix ];

  home-manager.users.liam = import ./home-shared.nix;
}
