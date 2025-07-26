{
  lib,
  pkgs,
  config,
  ...
}:
let
  ciSafe = builtins.getEnv "CI_SAFE" != "";
in
{
  imports = [ ./shared.nix ];

  nix.settings.trusted-users = [ "@admin" ];
  # nix.settings.sandbox = true;
  nix.daemonProcessType = "Interactive";
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
  }
  // lib.optionalAttrs (!ciSafe) {
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
      virtualisation.darwin-builder.memorySize = 512;
      # qemu-vm.nix tries to override this to empty with higher priority than
      # mkForce... grr...
      swapDevices = lib.mkOverride 5 [
        {
          device = "/var/lib/swapfile";
          size = 8 * 1024;
        }
      ];

      programs.fex.enable = true;

      environment.systemPackages = [ pkgs.pkgsLinux.btop ];
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

  environment.systemPackages = [
    pkgs.cctools # for otool
    pkgs.colima
    pkgs.docker
    # Workaround for https://github.com/rustwasm/wasm-bindgen/issues/3646.
    # I've been doing this since long before that issue was opened though, I should
    # really go fix it at some point.
    pkgs.gnused
    pkgs.musescore
    pkgs.skimpdf
    pkgs.utm
  ];

  users.users.liam.home = "/Users/liam";
  home-manager.users.liam = import ./home-mac.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
