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
  '';
}
