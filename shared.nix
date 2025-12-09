# Config that's shared between all my systems.
{ lib, pkgs, ... }:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
{
  imports = [ ./minimal.nix ];

  environment.systemPackages = [
    pkgs.binaryen
    pkgs.cargo-binutils
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.dafny
    pkgs.dotnet-runtime # TODO: is this actually needed (for Dafny)?
    pkgs.elan
    pkgs.emscripten # needed by tree-sitter
    pkgs.gnuplot
    pkgs.inkscape
    pkgs.isabelle
    pkgs.jre_headless # for kotlin-language-server
    pkgs.man-pages
    pkgs.nixd
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.opam
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
        biber
        collection-fontsextra
        collection-latexextra
        collection-mathscience
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
  ];

  fonts.packages = [ pkgs.gyre-fonts ];

  home-manager.users.liam = import ./home-shared.nix;
}
