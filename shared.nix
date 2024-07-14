# Config that's shared between all my systems.
{ pkgs, lib, ... }:
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "steam"
      "steam-original"
      "steam-run"
    ];

  nix.gc.automatic = true;
  nix.settings.keep-outputs = true;

  fonts.packages = [ pkgs.noto-fonts ];

  programs.fish.enable = true;
  users.users.liam.shell = pkgs.fish;
  home-manager.users.liam = import ./home-shared.nix;
}
