{ ... }:
{
  imports = [ ./minimal.nix ];

  nix.channel.enable = false;
  nix.settings.trusted-users = [ "liam" ];

  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Sydney";

  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.liam = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.gnupg.agent.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
  };

  documentation.man.generateCaches = false;
}
