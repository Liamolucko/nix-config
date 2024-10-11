# Config that's shared between all my systems.
{ pkgs, ... }:
{
  imports = [ ./minimal.nix ];

  environment.systemPackages = [
    pkgs.binaryen
    pkgs.cargo-binstall
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.emscripten # needed by tree-sitter
    # (pkgs.f4pga.override { installDir = pkgs.f4pga-arch-defs.xc7a50t; })
    pkgs.gtkwave
    pkgs.kitty
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.openfpgaloader
    pkgs.pulldown-cmark
    pkgs.prismlauncher
    pkgs.rclone
    pkgs.ruff
    pkgs.samply
    pkgs.stdenv.cc
    pkgs.tinymist
    pkgs.tree-sitter
    pkgs.typst
    pkgs.uv
    # pkgs.verible # broken on macos right now
    pkgs.verilator
    pkgs.vesktop
    pkgs.wabt
    pkgs.wasm-bindgen-cli
    pkgs.wasm-pack
    pkgs.wasm-tools
  ];

  home-manager.users.liam = import ./home-shared.nix;
}
