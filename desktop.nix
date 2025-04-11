{
  lib,
  pkgs,
  config,
  ...
}:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
  vivado = pkgs.vivado_2024_1.override {
    modules = [
      "Artix-7"
      "DocNav"
    ];
    # TODO: why is this working? I think it's putting things in Vivado/2024.2
    # instead of 2024.1.
    extraPaths = [ pkgs.digilent-board-files ];
  };
in
{
  imports = [ ./linux.nix ];

  # Hardware configuration
  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f96516cd-e441-45ed-9ccf-708a83c0c87d";
    fsType = "btrfs";
    options = [ "subvol=@nixos" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E014-9850";
    fsType = "vfat";
    # TODO: do I actually want this or did nixos-generate-config just needlessly inherit it from arch
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f96516cd-e441-45ed-9ccf-708a83c0c87d";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  # Other configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "liam-desktop";
  services.openssh.enable = true;

  environment.systemPackages =
    [
      pkgs.zed-editor
    ]
    ++ lib.optionals (!ciSafe) [
      vivado
    ];
  # Install Vivado's udev rules.
  services.udev.packages = lib.optionals (!ciSafe) [ vivado ];
  # Avoid accidentally GCing these if keep-outputs is turned off.
  system.extraDependencies = lib.optionals (!ciSafe) [
    vivado.payload
    pkgs.xinstall_2024_1.src
  ];

  system.stateVersion = "24.05";
}
