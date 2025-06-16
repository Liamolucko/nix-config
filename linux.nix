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
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;
  services.printing.browsed.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.libinput.enable = true;

  environment.systemPackages = [
    pkgs.gnome-tweaks
    pkgs.gnomeExtensions.caffeine
    pkgs.libreoffice
    pkgs.pciutils
    pkgs.rhythmbox
    pkgs.wl-clipboard
    (pkgs.runCommand "open" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.xdg-utils}/bin/xdg-open $out/bin/open
    '')
  ];

  programs.gpaste.enable = true;

  programs.firefox.enable = true;
  programs.firefox.preferences = {
    "apz.pangesture.delta_mode" = 2;
    "apz.pangesture.pixel_delta_mode_multiplier" = 25;
    "apz.gtk.touchpad_hold.enabled" = true;
  };

  programs.steam.enable = lib.mkDefault (!ciSafe);
  programs._1password-gui.enable = !ciSafe;

  home-manager.users.liam = import ./home-linux.nix;
}
