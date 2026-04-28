{ lib, pkgs, ... }:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
{
  imports = [
    ./shared.nix
    ./linux-minimal.nix
  ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.cosmic.enable = true;

  services.printing.enable = true;
  services.printing.browsed.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.libinput.enable = true;

  # TODO: clipboard history
  environment.systemPackages = [
    pkgs.caffeine-ng
    pkgs.ghostty
    pkgs.libreoffice-fresh
    pkgs.pciutils
    pkgs.rhythmbox
    pkgs.solaar
    pkgs.wl-clipboard
    pkgs.zed-editor
    (pkgs.runCommand "open" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.xdg-utils}/bin/xdg-open $out/bin/open
    '')
  ]
  ++ lib.optionals (!ciSafe) [ pkgs.obsidian ];
  services.udev.packages = [ pkgs.solaar ];

  services.flatpak.enable = true;

  programs.firefox.enable = true;
  programs.firefox.preferences = {
    "apz.pangesture.delta_mode" = 2;
    "apz.pangesture.pixel_delta_mode_multiplier" = 25;
    "apz.gtk.touchpad_hold.enabled" = true;

    "media.gmp-widevinecdm.version" = "system-installed";
    "media.gmp-widevinecdm.visible" = true;
    "media.gmp-widevinecdm.enabled" = true;
    "media.gmp-widevinecdm.autoupdate" = false;
  };

  environment.sessionVariables = lib.optionalAttrs (!ciSafe) {
    MOZ_GMP_PATH = "${pkgs.widevine-firefox}/gmp-widevinecdm/system-installed";
  };

  programs.steam.enable = lib.mkDefault (!ciSafe);
  programs._1password-gui.enable = !ciSafe;

  home-manager.users.liam = import ./home-linux.nix;
}
