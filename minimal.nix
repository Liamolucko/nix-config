{ lib, pkgs, ... }:
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

  environment.systemPackages = [
    pkgs.bat
    pkgs.btop
    pkgs.deno
    pkgs.file
    pkgs.gh
    pkgs.httplz
    pkgs.jq
    pkgs.nix-output-monitor
    pkgs.ripgrep
    pkgs.rsync
    pkgs.rustup
    (if pkgs.stdenv.isDarwin then pkgs.darwin.trash else pkgs.trashy)
  ];

  programs.fish.enable = true;
  users.users.liam.shell = pkgs.fish;

  home-manager.users.liam = import ./home-minimal.nix;
}
