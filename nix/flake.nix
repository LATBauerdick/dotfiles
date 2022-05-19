{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    /* nixpkgs.url = "nixpkgs/nixos-unstable"; */
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oh-my-posh = {
      url = "github:latbauerdick/oh-my-posh";
      /* url = "/data/dev/Dev/oh-my-posh"; */
      inputs.oh-my-posh.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    utils,
    oh-my-posh,
    ... }@inputs:
  let

    globalPkgsConfig = {
      allowUnfree = true;
    };
    localOverlay = _: _: { };
    pkgsForSystem = system: import nixpkgs {
      overlays = [
        localOverlay
      ];
      inherit system;
    };

    lib = nixpkgs.lib;
    mkVM = import ./lib/mkvm.nix;

  in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;

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

    nixosConfigurations.umini = mkVM "umini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };

    nixosConfigurations.utop = mkVM "utop" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };

    m1mac.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-darwin";
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      /* configuration.imports = [ ./users/bauerdic/home.nix ]; */
      extraSpecialArgs = { inherit nixpkgs oh-my-posh; };
      extraModules = [
        ./users/bauerdic/extraPackages.nix
      ];
      configuration = {
        imports = [ ./users/bauerdic/home.nix ];
        /* home.packages = [ inputs.nixpkgs.cargo ]; */
      };
      /* configuration = { config, pkgs, oh-my-posh, ... }: */
        /* let */
        /*   overlay-unstable = final: prev: { */
        /*     unstable = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin; */
        /*   }; */
        /* in */
        /* { */
        /*   home.packages = [ oh-my-posh ]; */
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
      extraSpecialArgs = { inherit nixpkgs oh-my-posh; };
      extraModules = [
        ./users/bauerdic/extraPackages.nix
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
    homeManagerConfigurationsIntel = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
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
