{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-os161.url = "github:Liamolucko/nix-os161";
    nix-os161.inputs.nixpkgs.follows = "nixpkgs";
    nix-xilinx.url = "gitlab:doronbehar/nix-xilinx";
    nix-xilinx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      nix-os161,
      nix-xilinx,
    }:
    let
      overlays = [
        nix-os161.overlays.default
        # note: this always builds for x86 regardless of the host system (which is what
        # I want).
        nix-xilinx.overlay
      ];
    in
    {
      darwinConfigurations."Liams-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { home-manager.users.liam.nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          ./mac.nix
        ];
      };

      nixosConfigurations."vivado-vm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          ./vivado-vm.nix
        ];
      };

      nixosConfigurations."test-vm" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          (
            { pkgs, ... }:
            {
              imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];

              programs.sway.enable = true;

              environment.systemPackages = [ pkgs.alacritty ];

              users.users.liam = {
                isNormalUser = true;
                home = "/home/liam";
                createHome = true;
                password = "password";
                extraGroups = [ "wheel" ];
              };

              virtualisation.host.pkgs = nixpkgs.legacyPackages."aarch64-darwin";

              system.stateVersion = "23.11";
            }
          )
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    });
}
