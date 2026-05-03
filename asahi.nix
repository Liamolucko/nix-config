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
                owner = "Liamolucko";
                tag = null;
                rev = "d92c52c8924ed8cc4306b1cd3b389eef1fcff895";
                hash = "sha256-ud2OGjeuNr23djMOnIUPHSbOMLl/0qTm6+H+QiXdaoI=";
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
