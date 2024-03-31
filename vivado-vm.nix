{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
  ];
  networking.useDHCP = lib.mkDefault true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  fileSystems."/mnt" = {
    device = "share";
    fsType = "virtiofs";
  };

  networking.hostName = "vivado-vm";

  nix.settings.experimental-features = "nix-command flakes";

  programs.fish.enable = true;
  users.users.vivado = {
    isNormalUser = true;
    home = "/home/vivado";
    createHome = true;
    password = "vivado";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
  home-manager.users.vivado = {
    home.username = "vivado";
    home.homeDirectory = "/home/vivado";
    home.file.".config/xilinx/nix.sh" = {
      text = ''
        INSTALL_DIR=/mnt/Xilinx
        VERSION=2023.2
      '';
    };
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };
  users.mutableUsers = false;

  environment.systemPackages = [
    pkgs.alacritty
    pkgs.git # needs to be installed to use flakes in git repos
    pkgs.vivado
    pkgs.xilinx-shell
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Shared memory is broken in Rosetta right now, so turn it off.
  # services.xserver.config = ''
  #   Section "Extensions"
  #     Option "MIT-SHM" "Disable"
  #   EndSection
  # '';
  nixpkgs.overlays = [
    (final: prev: {
      xwayland =
        let
          wrapper = final.writeShellScript "xwayland-wrapper" ''
            exec ${prev.xwayland}/bin/Xwayland -extension MIT-SHM $@
          '';
        in
        final.runCommand "xwayland-no-shm" { meta.mainProgram = "Xwayland"; } ''
          mkdir -p $out $out/bin
          ln -s ${wrapper} $out/bin/Xwayland
          ln -s ${prev.xwayland}/lib $out/lib
          ln -s ${prev.xwayland}/share $out/share
        '';
    })
  ];

  virtualisation.rosetta.enable = true;
  services.spice-vdagentd.enable = true;

  system.stateVersion = "23.11";
}
