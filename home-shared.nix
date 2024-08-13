{ pkgs, ... }:
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
    pkgs.nixd
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

    # COMP2511
    pkgs.gradle
    pkgs.jdt-language-server
  ];

  programs.java.enable = true;

  home.sessionVariables = {
    EDITOR = "zed --wait";
  };

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    theme = {
      mode = "system";
      light = "One Light";
      dark = "Xcode High Contrast Dark";
    };
    buffer_font_size = 14;
    features = {
      inline_completion_provider = "none";
    };
    assistant = {
      version = "2";
      enabled = false;
    };
    terminal = {
      dock = "bottom";
      alternate_scroll = "on";
      detect_venv = "off";
    };
    auto_install_extensions = {
      "fish" = true;
      "git-firefly" = true;
      "java-eclipse-jdtls" = true;
      "make" = true;
      "nix" = true;
      "ruff" = true;
      "scheme" = true;
      "toml" = true;
      "typst" = true;
      "verilog" = true;
      "wgsl" = true;
      "wit" = true;
      "xcode-themes" = true;
    };
    languages = {
      "Git Commit" = {
        wrap_guides = [ 72 ];
      };
      "Java" = {
        formatter = "language_server";
      };
      "Markdown" = {
        format_on_save = "on";
        soft_wrap = "editor_width";
      };
      "Nix" = {
        tab_size = 2;
        formatter = {
          external = {
            command = "nixfmt";
            arguments = [ ];
          };
        };
      };
      "Python" = {
        formatter = {
          language_server = {
            name = "ruff";
          };
        };
      };
      "Typst" = {
        soft_wrap = "editor_width";
      };
      "Verilog" = {
        tab_size = 2;
      };
    };
    "lsp" = {
      "rust-analyzer" = {
        initialization_options = {
          checkOnSave.command = "clippy";
          imports.granularity.group = "module";
        };
      };
      "tinymist" = {
        initialization_options = {
          formatterMode = "typstyle";
        };
      };
    };
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
