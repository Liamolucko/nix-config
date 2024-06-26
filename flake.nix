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
        calyx-lsp = final.callPackage ./pkgs/calyx-lsp { };
        # TODO: fasm has a binary that we should package but there's already something
        # else with that name, what to call it?
        f4pga = with final.python3Packages; toPythonApplication f4pga;
        f4pga-arch-defs = final.callPackage ./pkgs/f4pga-arch-defs.nix { };
        fex = final.callPackage ./pkgs/fex.nix { };
        llvm-mctoll = final.callPackage ./pkgs/llvm-mctoll.nix { };
        prjxray = with final.python3Packages; toPythonApplication prjxray;
        prjxray-db = final.callPackage ./pkgs/prjxray-db.nix { };
        prjxray-tools = final.callPackage ./pkgs/prjxray-tools.nix { };
        rsyntaxtree = final.callPackage ./pkgs/rsyntaxtree { };
        spade-language-server = final.callPackage ./pkgs/spade-language-server { };
        swim = final.callPackage ./pkgs/swim { };
        vivado = final.callPackage ./pkgs/vivado { };
        vtr = final.callPackage ./pkgs/vtr { };
        xc-fasm = with final.python3Packages; toPythonApplication xc-fasm;
        xilinx-installer = final.callPackage ./pkgs/xilinx-installer { };

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            fasm = python-final.callPackage ./pkgs/fasm.nix { };
            # We want the application version of xc-fasm, not the package version.
            f4pga = python-final.callPackage ./pkgs/f4pga { xc-fasm = final.xc-fasm; };
            xc-fasm = python-final.callPackage ./pkgs/xc-fasm { };
            prjxray = python-final.callPackage ./pkgs/prjxray.nix { };
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

      nixosConfigurations."liam-desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { home-manager.users.liam.nixpkgs.overlays = overlays; }
          home-manager.nixosModules.home-manager
          ./desktop.nix
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
