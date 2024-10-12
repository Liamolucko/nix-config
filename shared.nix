# Config that's shared between all my systems.
{ pkgs, ... }:
{
  imports = [ ./minimal.nix ];

  environment.systemPackages = [
    pkgs.binaryen
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.emscripten # needed by tree-sitter
    # (pkgs.f4pga.override { installDir = pkgs.f4pga-arch-defs.xc7a50t; })
    pkgs.kitty
    pkgs.isabelle
    pkgs.jre_headless # for kotlin-language-server
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.openfpgaloader
    pkgs.pulldown-cmark
    pkgs.prismlauncher
    pkgs.rclone
    pkgs.ruff
    (pkgs.lib.meta.hiPrio pkgs.rust-analyzer)
    pkgs.samply
    pkgs.surfer
    pkgs.tinymist
    pkgs.tree-sitter
    pkgs.typst
    pkgs.uv
    # pkgs.verible # broken on macos right now
    pkgs.vesktop
    pkgs.wabt
    pkgs.wasm-bindgen-cli
    pkgs.wasm-pack
    pkgs.wasm-tools
  ];
  fonts.packages = [ pkgs.ibm-plex ];

  home-manager.users.liam = import ./home-shared.nix;
}
