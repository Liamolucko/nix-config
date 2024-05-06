{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
      nix-xilinx,
    }:
    let
      overlays = [
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
        llvm-mctoll = final.callPackage ./pkgs/llvm-mctoll.nix { };
        prjxray-db = final.callPackage ./pkgs/prjxray-db.nix { };
        prjxray-tools = final.callPackage ./pkgs/prjxray-tools.nix { };
        vtr = final.callPackage ./pkgs/vtr.nix { };

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            fasm = python-final.callPackage ./pkgs/fasm.nix { };
            f4pga = python-final.callPackage ./pkgs/f4pga.nix { };
            xc-fasm = python-final.callPackage ./pkgs/xc-fasm.nix { };
            prjxray = python-final.callPackage ./pkgs/prjxray.nix { };
            pyjson5 = python-final.callPackage ./pkgs/pyjson5.nix { };
          })
        ];
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
        pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = pkgs;
      }
    );
}
