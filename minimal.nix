{ lib, pkgs, ... }:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    !ciSafe
    && builtins.elem (lib.getName pkg) [
      "1password"
      "docnav"
      "drawio"
      "obsidian"
      "rgp"
      "steam"
      "steam-unwrapped"
      "vivado"
      "widevine-cdm"
      "widevine-firefox"
      "xinstall"
    ];

  nix.gc.automatic = true;
  nix.gc.options = "--option keep-outputs true";
  nix.optimise.automatic = true;
  nix.settings.diff-hook = pkgs.writeShellScript "diff-hook" ''
    exec >&2
    echo "For derivation $3:"
    /run/current-system/sw/bin/diff -r "$1" "$2"
  '';
  nix.settings.run-diff-hook = true;
  nix.package = pkgs.lix;

  nix.settings.substituters = [
    "https://liamolucko.cachix.org"
    "https://nix-cache.fossi-foundation.org"
  ];
  nix.settings.trusted-public-keys = [
    "liamolucko.cachix.org-1:BUnxmHPZZOBq0CokNOYCcYBOCzFXJ9EjdY9BoQkDVJY="
    "nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs="
  ];

  environment.systemPackages = [
    pkgs.bat
    pkgs.btop
    pkgs.file
    pkgs.gh
    pkgs.jq
    pkgs.nix-output-monitor
    pkgs.python3
    pkgs.ripgrep
    pkgs.rsync
    pkgs.rustup
    (if pkgs.stdenv.isDarwin then pkgs.darwin.trash else pkgs.trashy)
  ];

  services.tailscale.enable = true;

  programs.fish.enable = true;
  users.users.liam.shell = pkgs.fish;

  home-manager.users.liam = import ./home-minimal.nix;
}
