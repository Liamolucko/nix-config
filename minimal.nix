{ lib, pkgs, ... }:
{
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "steam"
      "steam-unwrapped"
      "vivado"
      "xinstall"
    ];

  nix.gc.automatic = true;
  nix.optimise.automatic = true;
  nix.settings.keep-outputs = true;
  nix.settings.diff-hook = pkgs.writeShellScript "diff-hook" ''
    exec >&2
    echo "For derivation $3:"
    /run/current-system/sw/bin/diff -r "$1" "$2"
  '';
  nix.settings.run-diff-hook = true;
  nix.package = pkgs.lix;

  nix.settings.substituters = [ "https://liamolucko.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "liamolucko.cachix.org-1:BUnxmHPZZOBq0CokNOYCcYBOCzFXJ9EjdY9BoQkDVJY="
  ];

  environment.systemPackages = [
    pkgs.bat
    (pkgs.btop.override { rocmSupport = pkgs.stdenv.system == "x86_64-linux"; })
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
