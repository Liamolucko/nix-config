{ pkgs, config, ... }:
{
  imports = [ ./shared.nix ];

  nix.settings.trusted-users = [ "@admin" ];
  services.nix-daemon.enable = true;
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 8;
    systems = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
    ];
    config = {
      imports = [ modules/fex.nix ];
      nixpkgs.overlays = config.nixpkgs.overlays;

      # QEMU can only start VMs with 8 cores right now for some reason.
      virtualisation.cores = 8;
      # The default 3GB doesn't seem to be enough for f4pga-arch-defs.
      virtualisation.darwin-builder.memorySize = 8 * 1024;
      # Vivado is ~30GB, so use a 60GB disk for some breathing room.
      virtualisation.darwin-builder.diskSize = 60 * 1024;

      programs.fex.enable = true;
    };
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
    casks = [
      "eloston-chromium"
      "firefox"
    ];
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };
  };

  environment.systemPackages = [
    pkgs.colima
    pkgs.docker
    # Workaround for https://github.com/rustwasm/wasm-bindgen/issues/3646.
    # I've been doing this since long before that issue was opened though, I should
    # really go fix it at some point.
    pkgs.gnused
    pkgs.musescore
    pkgs.utm
  ];

  users.users.liam.home = "/Users/liam";
  home-manager.users.liam = import ./home-mac.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
