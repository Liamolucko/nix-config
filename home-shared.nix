{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "${if pkgs.stdenv.isLinux then "zeditor" else "zed"} --wait";
  };

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    theme = {
      mode = "system";
      light = "One Light";
      dark = "Xcode High Contrast Dark";
    };
    buffer_font_size = 14;
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
    };
    auto_install_extensions = {
      "fish" = true;
      "git-firefly" = true;
      "kotlin" = true;
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
    lsp = {
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
      nathanridley.autotrim
      pkief.material-icon-theme
      llvm-vs-code-extensions.vscode-clangd
      ms-vsliveshare.vsliveshare
      mateocerquetella.xcode-12-theme
    ];
    userSettings = {
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.bracketPairColorization.enabled" = false;
      "editor.fontFamily" = "'IBM Plex Mono', monospace";
      "editor.fontSize" = 15;
      "editor.formatOnSave" = true;
      "editor.inlayHints.enabled" = "off";
      "editor.minimap.enabled" = false;
      "editor.smoothScrolling" = true;
      "editor.suggest.showWords" = false;
      "terminal.integrated.cursorStyle" = "underline";
      "terminal.integrated.fontSize" = 15;
      "workbench.colorTheme" = "Xcode Default (Dark Customized Version)";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      "[c]" = {
        "editor.formatOnSave" = false;
      };
      "[cpp]" = {
        "editor.formatOnSave" = false;
      };
    };
  };
}
