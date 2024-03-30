{ pkgs, ... }:
{
  home.packages = [
    pkgs.cargo-binstall
    pkgs.binaryen
    pkgs.deno
    pkgs.emscripten # needed by tree-sitter
    pkgs.geckodriver
    pkgs.gh
    pkgs.gnupg
    pkgs.gtkwave
    pkgs.nixfmt-rfc-style
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.rsync
    pkgs.tree-sitter
    pkgs.typst
    # pkgs.verible # broken on macos right now
    pkgs.verilator
    pkgs.wabt
    pkgs.wasm-pack
    pkgs.wasm-tools

    # COMP6991
    pkgs.cargo-insta

    # COMP3891
    pkgs.bear
    pkgs.bmake
    pkgs.os161-binutils
    pkgs.os161-gcc
    pkgs.os161-gdb
    pkgs.sys161
  ];

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

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
