{
  lib,
  pkgs,
  config,
  ...
}:
let
  alacritty-mac-icon-svg = pkgs.fetchurl {
    url = "https://gist.github.com/jdsimcoe/8760878212c4001216a738d2111dcb33/raw/baa76575f8e840d74cd89042638f6a52825908e2/alacritty.svg";
    hash = "sha256-mKHYrxttqyXmb2JL8BcUVWin2387n78PFGMF/8gA/MM=";
  };
  alacritty-mac-icons = pkgs.runCommand "alacritty-mac-icons" { } ''
    ${lib.getExe pkgs.cargo-tauri} icon ${alacritty-mac-icon-svg} -o $out
  '';
  alacritty-mac = pkgs.runCommand pkgs.alacritty.name { } ''
    mkdir $out
    ${lib.getExe pkgs.xorg.lndir} ${pkgs.alacritty} $out
    rm $out/Applications/Alacritty.app/Contents/Resources/alacritty.icns
    cp ${alacritty-mac-icons}/icon.icns $out/Applications/Alacritty.app/Contents/Resources/alacritty.icns
  '';
in
{
  home.sessionVariables = {
    EDITOR = "${if pkgs.stdenv.isLinux then "zeditor" else "zed"} --wait";
    HOLDIR = "${config.home.homeDirectory}/src/HOL";
    CAKEMLDIR = "${config.home.homeDirectory}/src/cakeml";
    CHESHIREDIR = "${config.home.homeDirectory}/src/cheshire";
    HARDWAREDIR = "${config.home.homeDirectory}/src/cakeml-hardware";
  };

  programs.alacritty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then alacritty-mac else pkgs.alacritty;
    settings.general.import = [ "${pkgs.alacritty-theme}/dracula.toml" ];
  };

  xdg.configFile."zed/settings.json".source = pkgs.runCommand "zed-settings" { } ''
    ln -s '${config.home.homeDirectory}/src/nix-config/dotfiles/zed-settings.json' $out
  '';

  programs.emacs.enable = true;
  programs.emacs.extraConfig = ''
    (load "/Users/liam/src/HOL/tools/editor-modes/emacs/hol-mode")
    (load "/Users/liam/src/HOL/tools/editor-modes/emacs/hol-unicode")

    (delete-selection-mode 1)
    (global-set-key [home] 'move-beginning-of-line)
    (global-set-key [end] 'move-end-of-line)
    (xterm-mouse-mode t)
  '';

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    profiles.default.extensions = with pkgs.vscode-marketplace; [
      iliazeus.vscode-ansi
      pkgs.open-vsx.jeanp413.open-remote-ssh
      leanprover.lean4
      mateocerquetella.xcode-12-theme
      maximedenes.vscoq
      nathanridley.autotrim
      oskarabrahamsson.hol4-mode
      pkief.material-icon-theme
      stkb.rewrap
      tamasfe.even-better-toml
    ];
  };

  home.file."Library/Application Support/VSCodium/User/settings.json".source =
    pkgs.runCommand "vscode-settings" { }
      ''
        ln -s '${config.home.homeDirectory}/src/nix-config/dotfiles/vscode-settings.json' $out
      '';
}
