{
  lib,
  config,
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
  boot.kernelPackages =
    let
      pkgs' = config.hardware.asahi.pkgs;
    in
    lib.mkForce (
      (pkgs'.linux-asahi.override {
        _kernelPatches = config.boot.kernelPatches;
      }).extend
        (
          final: prev: {
            kernel = prev.kernel.overrideAttrs (old: {
              src = old.src.override {
                tag = null;
                rev = "77e0fe0c47e847221988f6397167bc23fec2a042";
                hash = "sha256-wnNrbpa3dYceQU7ZeJ7eJH6k9QMqswctK/4xxGI9SZE=";
              };
            });
          }
        )
    );

  networking.hostName = "liam-asahi";

  hardware.asahi.extractPeripheralFirmware = !ciSafe;

  # TODO: get working w/ FEX.
  programs.steam.enable = false;

  system.stateVersion = "24.05";
}
