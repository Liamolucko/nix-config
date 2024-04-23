{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-os161.url = "github:Liamolucko/nix-os161";
    nix-os161.inputs.nixpkgs.follows = "nixpkgs";
    nix-xilinx.url = "gitlab:doronbehar/nix-xilinx";
    nix-xilinx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      nix-vscode-extensions,
      nix-os161,
      nix-xilinx,
    }:
    let
      overlays = [
        nix-vscode-extensions.overlays.default
        nix-os161.overlays.default
        # note: this always builds for x86 regardless of the host system (which is what
        # I want).
        nix-xilinx.overlay
        self.overlays.default
      ];
    in
    {
      overlays.default = final: prev: {
        calyx-lsp = final.callPackage ./pkgs/calyx-lsp.nix { };
        fex = final.callPackage ./pkgs/fex.nix { };
      };

      darwinConfigurations."Liams-Laptop" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { home-manager.users.liam.nixpkgs.overlays = overlays; }
          home-manager.darwinModules.home-manager
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
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        overlay = self.overlays.default pkgs pkgs;
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = overlay;
      }
    );
}
