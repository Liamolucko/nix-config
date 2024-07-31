{ lib, pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./linux-minimal.nix
  ];

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  services.libinput.enable = true;

  programs.steam.enable = lib.mkDefault true;
  programs._1password-gui.enable = true;

  home-manager.users.liam = import ./home-linux.nix;
}
