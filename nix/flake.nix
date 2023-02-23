{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
#    nixpkgs.url = "/home/bauerdic/nixpkgs"; # sudo git config --global --add safe.directory /home/bauerdic/nixpkgs
    home-manager = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-22.11";
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

    globalPkgsConfig = {
      allowUnfree = true;
    };
    localOverlay = _: _: { };
    pkgsForSystem = system: import nixpkgs {
      # overlays = [ localOverlay ];
      inherit system;
    };

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
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;

    nixosConfigurations.xmini = mkMachine "xmini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };
    nixosConfigurations.umini = mkMachine "umini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };

    nixosConfigurations.usrv = mkMachine "usrv" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };


    intel.bauerdic = home-manager.lib.homeManagerConfiguration {
     # nixosModules.home = import ./users/bauerdic/home.nix; # attr set or list
      system = "x86_64-linux";
      configuration.imports = [ ./users/bauerdic/home.nix ];
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
        networkInterface = "xxx";
      };
    };

    m1mac.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-darwin";
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      /* configuration.imports = [ ./users/bauerdic/home.nix ]; */
      extraSpecialArgs = { inherit nixpkgs; };
      extraModules = [
        /* ./users/bauerdic/extraPackages.nix */
      ];
      configuration = {
        imports = [ ./users/bauerdic/home.nix ];
        /* home.packages = [ inputs.nixpkgs.cargo ]; */
      };
      /* configuration = { config, pkgs, ... }: */
        /* let */
        /*   overlay-unstable = final: prev: { */
        /*     unstable = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin; */
        /*   }; */
        /* in */
        /* { */
        /*   home.packages = [ ]; */
        /*   /1* nixpkgs.overlays = [ overlay-unstable ]; *1/ */
        /*   nixpkgs.config = { */
        /*     allowUnfree = true; */
        /*     allowBroken = true; */
        /*   }; */
        /*   imports = [ ./users/bauerdic/home.nix ]; */
        /* }; */
    };
    bauerdic = self.homeConfigurations.bauerdic.activationPackage;
    defaultPackage.aarch64-darwin = self.bauerdic;

    umini.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      extraSpecialArgs = { inherit nixpkgs; };
      extraModules = [
        /* ./users/bauerdic/extraPackages.nix */
      ];
      configuration = {
        imports = [ ./users/bauerdic/home.nix ];
      };
    };

    intelmac.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-darwin";
      pkgs = import nixpkgs {
        system = "x86_64-darwin";
        config = { allowUnfree = true; };
      };
      username = "bauerdic";
      homeDirectory = "/home/bauerdic";
      configuration = {
        imports = [
          ./users/bauerdic/home.nix
        ];
      };
    };
    lima = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
        system = "aarch64-linux";
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config = { allowUnfree = true; };
        };
        username = "bauerdic";
        homeDirectory = "/home/bauerdic";
        configuration = {
          imports = [
            ./users/bauerdic/home.nix
          ];
        };
      };
    };
  };
}
