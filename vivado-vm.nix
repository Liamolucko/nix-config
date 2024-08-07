{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ modules/fex.nix ];

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
    initialPassword = "vivado";
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

  environment.systemPackages = [
    pkgs.git # needs to be installed to use flakes in git repos
    pkgs.kitty
    # Note to self: enshrine the LIBRARY_PATH workaround in nix-xilinx
    # (or figure out why it works on arch)
    # also make it compatible with FEX etc.
    # pkgs.vivado
    pkgs.xilinx-shell
  ];

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
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

  # boot.binfmt.registrations.box64 = {
  #   interpreter = lib.getExe pkgs.box64;
  #   # Copied from `magics` in `<nixpkgs>/nixos/modules/system/boot/binfmt.nix`.
  #   magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
  #   mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  # };
  # nix.settings.extra-platforms = [ "x86_64-linux" ];
  # programs.fex.enable = true;

  virtualisation.rosetta.enable = true;
  services.spice-vdagentd.enable = true;

  system.stateVersion = "23.11";
}
