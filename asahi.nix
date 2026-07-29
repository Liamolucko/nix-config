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
          url = "https://github.com/AsahiLinux/linux/commit/19f8a0521912b183036812764161d476bf10c6b8.diff?full_index=1";
          hash = "sha256-o26a7vhXrOLh1DMJWq00urJCjl/K0qJ/xMli/MohVzs=";
        }
      );
    }
    {
      name = "usb: typec: tipd: HACK: Use drm oob hotplug event";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/ecb9073f2e4b578762bcbdadf46495502ca2f13b.diff?full_index=1";
          hash = "sha256-1gB/5p6hwbtyHAfJk0dvlfJ8WFGToWlVda7ueBu8jjQ=";
        }
      );
    }
    {
      name = "arm64: dts: apple: t60xx: j[34]1[46]: Add dp-altmode hacks";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/e4bd0f159ed29032e38b576cf51cc725bda2fcf2.diff?full_index=1";
          hash = "sha256-I8wXioDRgkQq789dJxUP7M8MSLk7Vsn8DqUPF8y4/I0=";
        }
      );
    }
    {
      name = "HACK: arm64: dts: apple: t60xx: j[34]1[46]: Mark ps_atc1_common as always on";
      patch = (
        pkgs.fetchpatch2 {
          url = "https://github.com/AsahiLinux/linux/commit/449d9961a37ebb98034f0792d6d377ee3ccb5c65.diff?full_index=1";
          hash = "sha256-zPHCI2SOEfehoGJdx4dXxffzrgqfpuqxNA+uOKJw/1g=";
        }
      );
    }
  ];

  networking.hostName = "liam-asahi";

  hardware.asahi.extractPeripheralFirmware = !ciSafe;

  # TODO: get working w/ FEX.
  programs.steam.enable = false;

  system.stateVersion = "24.05";
}
