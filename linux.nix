{ pkgs, ... }:
{
  imports = [ ./shared.nix ];

  nix.channel.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Sydney";

  i18n.defaultLocale = "en_AU.UTF-8";

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  services.libinput.enable = true;

  users.users.liam = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.gnupg.agent.enable = true;

  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
  };

  programs.steam.enable = true;
  programs._1password-gui.enable = true;

  home-manager.users.liam = import ./home-linux.nix;
}
