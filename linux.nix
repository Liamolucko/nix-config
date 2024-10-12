{ lib, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./linux-minimal.nix
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.libinput.enable = true;

  environment.systemPackages = [
    pkgs.firefox
    pkgs.gnome-tweaks
    pkgs.gnomeExtensions.caffeine
    pkgs.gpaste
    pkgs.kdePackages.kclock
    pkgs.libreoffice
    pkgs.rhythmbox
    pkgs.usbutils
    (pkgs.runCommand "open" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.xdg-utils}/bin/xdg-open $out/bin/open
    '')
  ];

  programs.steam.enable = lib.mkDefault true;
  programs._1password-gui.enable = true;

  home-manager.users.liam = import ./home-linux.nix;
}
