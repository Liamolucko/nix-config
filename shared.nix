# Config that could theoretically, in future, be shared between all my systems.
{ pkgs, ... }:
{
  nix.settings.experimental-features = "nix-command flakes";
  services.nix-daemon.enable = true;
  nix.gc.automatic = true;

  programs.fish.enable = true;
  users.users.liam.shell = pkgs.fish;
  home-manager.users.liam = import ./home-shared.nix;
}
