{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "/home/bauerdic/nixpkgs"; # sudo git config --global --add safe.directory /home/bauerdic/nixpkgs
    home-manager = {
#      url = "github:nix-community/home-manager";
      url = "/home/bauerdic/home-manager"; # sudo git config --global --add safe.directory /home/bauerdic/home-manager
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oh-my-posh = {
      url = "github:latbauerdick/oh-my-posh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    utils,
    ... }@inputs:
  let

    pkgsForSystem = system: import nixpkgs { inherit system; };

    mkMachine = name: { nixpkgs, home-manager, system, user }: nixpkgs.lib.nixosSystem rec {
      inherit system;
      modules = [
        ./hardware/${name}.nix
        ./machines/${name}.nix
        ./users/${user}/user.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./users/${user}/home.nix;
        }
        { nixpkgs.overlays = import ./overlays.nix ++ [ ]; }
      ];
    };

  in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = import nixpkgs { inherit system; };
  }) // {
    nixosConfigurations.umini = mkMachine "umini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };
  };
}