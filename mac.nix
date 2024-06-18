{ pkgs, ... }:
{
  imports = [ ./shared.nix ];

  nix.settings.trusted-users = [ "@admin" ];
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 8;
    config = {
      # QEMU can only start VMs with 8 cores right now for some reason.
      virtualisation.cores = 8;
      # Allow building x86 stuff.
      boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
    };
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };

  # Workaround for https://github.com/zed-industries/zed/issues/4360.
  system.patches = [
    (pkgs.writeText "no-send-locale.patch" ''
      --- a/etc/ssh/ssh_config
      +++ b/etc/ssh/ssh_config
      @@ -51,5 +51,3 @@
       #   ProxyCommand ssh -q -W %h:%p gateway.example.com
       #   RekeyLimit 1G 1h
       #   UserKnownHostsFile ~/.ssh/known_hosts.d/%k
      -Host *
      -    SendEnv LANG LC_*
    '')
  ];

  homebrew = {
    enable = true;
    taps = [ "macos-fuse-t/homebrew-cask" ];
    casks = [
      "eloston-chromium"
      "firefox"
      "fuse-t"
      "fuse-t-sshfs"
    ];
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };
  };

  users.users.liam.home = "/Users/liam";
  home-manager.users.liam = import ./home-mac.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
