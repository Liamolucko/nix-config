# Config that's shared between all my systems.
{ lib, pkgs, ... }:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
{
  imports = [ ./minimal.nix ];

  environment.systemPackages = [
    pkgs.binaryen
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.coq_8_20
    pkgs.coqPackages_8_20.vscoq-language-server
    pkgs.emscripten # needed by tree-sitter
    pkgs.gnuplot
    pkgs.inkscape
    pkgs.jre_headless # for kotlin-language-server
    pkgs.elan
    pkgs.man-pages
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.openfpgaloader
    pkgs.pulldown-cmark
    pkgs.rclone
    pkgs.ruff
    (pkgs.lib.meta.hiPrio pkgs.rust-analyzer)
    pkgs.samply
    pkgs.surfer
    pkgs.texlab
    (pkgs.texlive.combine {
      inherit (pkgs.texlive)
        collection-fontsextra
        collection-fontsrecommended
        collection-latexextra
        scheme-small
        ;
    })
    pkgs.tinymist
    pkgs.tree-sitter
    pkgs.typst
    pkgs.usbutils
    pkgs.uv
    # pkgs.verible # broken on macos right now
    pkgs.verilator
    pkgs.vesktop
    pkgs.wabt
    pkgs.wasm-bindgen-cli
    pkgs.wasm-pack
    pkgs.wasm-tools
    pkgs.wgsl-analyzer
  ]
  ++ lib.optionals (!ciSafe) [
    pkgs.drawio
    pkgs.isabelle
  ];

  fonts.packages = [ pkgs.gyre-fonts ];

  home-manager.users.liam = import ./home-shared.nix;
}
