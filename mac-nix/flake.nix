{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    /* nixpkgs.url = "github:nixos/nixpkgs/release-21.11"; */
    /* nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; */
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      # url = "github:nix-community/home-manager/release-21.05";
      url = "github:nix-community/home-manager";
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

    nixosConfigurations.intel = mkVM "intel" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };

    m1mac.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-darwin";
      /* pkgs = import nixpkgs { */
      /*   system = "aarch64-darwin"; */
      /*   config = { allowUnfree = true; }; */
      /* }; */
      username = "bauerdic";
      homeDirectory = "/home/bauerdic";
      configuration.imports = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
        networkInterface = "xxx";
      };
    };
    homeManagerConfigurationsMac = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
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
    };
    homeManagerConfigurationsLima = {
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
