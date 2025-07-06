{ pkgs, ... }:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
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

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # Other configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "liam-asahi";

  hardware.asahi.extractPeripheralFirmware = !ciSafe;
  hardware.asahi.useExperimentalGPUDriver = true;

  environment.systemPackages = [ pkgs.zed-editor ];

  # TODO: get working w/ FEX.
  programs.steam.enable = false;

  system.stateVersion = "24.05";
}
