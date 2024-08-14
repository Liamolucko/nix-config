{ pkgs, lib, ... }:
let
  vivado = pkgs.pkgsx86_64Linux.vivado.override {
    modules = [ "Artix-7" ];
    extraPaths = [ pkgs.digilent-board-files ];
  };
in
{
  imports = [
    ./linux-minimal.nix
    modules/fex.nix
  ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
  ];
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

  environment.systemPackages = [ vivado ];

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
