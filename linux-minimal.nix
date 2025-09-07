{ pkgs, ... }:
{
  imports = [ ./minimal.nix ];

  nix.channel.enable = false;
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [ "liam" ];

  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.liam = {
    isNormalUser = true;
    extraGroups = [
      "disk"
      "wheel"
    ];
  };

  programs.gnupg.agent.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
  };

  boot.kernel.sysctl = {
    # Needed by samply.
    "kernel.perf_event_paranoid" = 1;
  };

  documentation.man.generateCaches = false;

  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
