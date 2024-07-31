{ modulesPath, pkgs, ... }:
{
  imports = [
    ./linux-minimal.nix
    modules/fex.nix
  ];

  # Hardware configuration
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  # Other configuration
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi4";
  services.openssh.enable = true;

  environment.systemPackages = [ pkgs.kitty.terminfo ];
  programs.fex.enable = true;

  system.stateVersion = "24.05";
}
