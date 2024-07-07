{
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.match "vivado-.*" (lib.getName pkg) != null
    || builtins.elem (lib.getName pkg) [ "xinstall" ];

  home.packages = [
    pkgs.btop
    pkgs.calyx-lsp
    pkgs.cargo-binstall
    pkgs.cargo-expand
    pkgs.cargo-fuzz
    pkgs.clang-tools
    pkgs.bat
    pkgs.binaryen
    pkgs.deno
    pkgs.emscripten # needed by tree-sitter
    # (pkgs.f4pga.override { installDir = pkgs.f4pga-arch-defs.xc7a50t; })
    pkgs.file
    pkgs.gh
    pkgs.gnupg
    pkgs.gtkwave
    pkgs.httplz
    pkgs.jq
    pkgs.kitty
    pkgs.nix-output-monitor
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.openfpgaloader
    pkgs.pulldown-cmark
    pkgs.rclone
    pkgs.ripgrep
    pkgs.rsync
    pkgs.ruff
    pkgs.rustup
    pkgs.samply
    pkgs.spade-language-server
    pkgs.stdenv.cc
    pkgs.swim
    pkgs.tree-sitter
    pkgs.typst
    pkgs.uv
    # pkgs.verible # broken on macos right now
    pkgs.verilator
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
    # R = don't mess with control characters (i.e. make colours work)
    # S = truncate lines instead of wrapping
    #
    # As well as wanting it to behave that way, another reason I'm setting this is
    # because it stops Git from setting it and setting X, which breaks mouse
    # scrolling.
    LESS = "RS";
    PGDATA = "${config.home.homeDirectory}/.local/share/postgresql";
  };

  # This needs to be specified both inside and outside of home-manager, so that
  # outside it I can set fish as my shell and inside it I can configure stuff.
  programs.fish.enable = true;
  # A slight modification from the default fish prompt, that just gets rid of the
  # `user@host` bit.
  programs.fish.functions.fish_prompt = ''
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status --background=red white

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
  '';
  programs.fish.shellInit = ''
    set fish_greeting ""
  '';

  programs.git = {
    enable = true;
    userName = "Liam Murphy";
    userEmail = "liampm32@gmail.com";
    signing = {
      key = "0A01FCF4B19F9B8D";
      signByDefault = true;
    };
    delta = {
      enable = true;
      # Delta's light/dark detection seems to somehow cause it to start off scrolled
      # to the right in Zed's terminal, so tell it we're using dark mode up front to
      # get it to skip detecting it; TODO file an issue about this
      options.dark = true;
    };
    extraConfig = {
      push.autoSetupRemote = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
