{ pkgs, ... }:
{
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
    # Needed for some of the symbols nix-output-monitor uses.
    # (This doesn't actually work yet but should once nixpkgs gets Zed 0.147.2.)
    buffer_font_fallbacks = [ "Noto Sans Symbols 2" ];
    auto_update = pkgs.stdenv.isDarwin;
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
