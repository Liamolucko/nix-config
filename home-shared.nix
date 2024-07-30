{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [
    pkgs.binaryen
    pkgs.cargo-binstall
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.emscripten # needed by tree-sitter
    # (pkgs.f4pga.override { installDir = pkgs.f4pga-arch-defs.xc7a50t; })
    pkgs.gtkwave
    pkgs.kitty
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.openfpgaloader
    pkgs.pulldown-cmark
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

    # ARTS2692
    pkgs.rsyntaxtree

    # COMP2511
    pkgs.gradle
    pkgs.jdt-language-server

    # COMP3311
    pkgs.postgresql
  ];

  programs.java.enable = true;

  home.sessionVariables = {
    EDITOR = "zed --wait";
    PGDATA = "${config.home.homeDirectory}/.local/share/postgresql";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-marketplace; [
      mateocerquetella.xcode-12-theme
      nathanridley.autotrim
      pkief.material-icon-theme
      redhat.java
      vscjava.vscode-java-debug
      vscjava.vscode-java-pack # does nothing but makes vscode shut up about recommended extensions
      vscjava.vscode-java-test
    ];
    userSettings = {
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.bracketPairColorization.enabled" = false;
      "editor.fontFamily" = "'Zed Mono', monospace";
      "editor.fontSize" = 15;
      "editor.formatOnSave" = true;
      "editor.inlayHints.enabled" = "off";
      "editor.minimap.enabled" = false;
      "editor.smoothScrolling" = true;
      "editor.suggest.showWords" = false;
      "redhat.telemetry.enabled" = false;
      "terminal.integrated.cursorStyle" = "underline";
      "terminal.integrated.fontSize" = 15;
      "workbench.colorTheme" = "Xcode Default (Dark Customized Version)";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
    };
  };
}
