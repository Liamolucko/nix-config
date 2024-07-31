{ config, ... }:
{
  imports = [ ./linux.nix ];

  # Hardware configuration
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "sdhci_pci"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0a4e816e-ae88-407c-8c9d-cecf3a4e2f3f";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0a4e816e-ae88-407c-8c9d-cecf3a4e2f3f";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/863D-1D15";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # Other configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # The default detection doesn't seem to work with flakes.
  hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  networking.networkmanager.wifi.backend = "iwd";

  networking.hostName = "liam-asahi";

  # TODO: get working w/ FEX.
  programs.steam.enable = false;

  system.stateVersion = "24.05";
}
