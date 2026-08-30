{
  pkgs,
  ...
}:
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
      size = 32 * 1024;
    }
  ];

  # Other configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # fairydust DP alt mode branch
  boot.kernelPatches = [
    {
      name = "usb: typec: tipd: Track data_status changes for CD321x";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/ca77753b966c8ce4e9412b0863de0c4d89b147fe.diff?full_index=1";
          hash = "sha256-NZy1UAYlPdWvMLwknFkdCYKmpI/8IlP0yUvfBTdfVxw=";
        }
      );
    }
    {
      name = "usb: typec: tipd: HACK: Use drm oob hotplug event";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/7a95896e0cd9440176b1595f0961de8f595ea44e.diff?full_index=1";
          hash = "sha256-gi0fqMXu/w0sIf0zZgbF7PI1PZmKuZogdsbpt4UkCU8=";
        }
      );
    }
    {
      name = "arm64: dts: apple: t60xx: j[34]1[46]: Add dp-altmode hacks";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/29cf6a0512f3cf007359387ccff66059eaefefa7.diff?full_index=1";
          hash = "sha256-/c5HLam1Phc2+7CPK2Wal4W9Fs/HXHI6cCZi6H1pa8M=";
        }
      );
    }
    {
      name = "HACK: arm64: dts: apple: t60xx: j[34]1[46]: Mark ps_atc1_common as always on";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/c471dd3ed9dd97f4cbac779443e6e35760970e7e.diff?full_index=1";
          hash = "sha256-PFaw8+Uu3ls7SOkIW4L0rGrLb/8r+TdyA+3r4JXggBA=";
        }
      );
    }
  ];

  networking.hostName = "liam-asahi";

  hardware.asahi.enable = true;
  hardware.asahi.extractPeripheralFirmware = !ciSafe;

  # TODO: get working w/ FEX.
  programs.steam.enable = false;

  system.stateVersion = "24.05";
}
