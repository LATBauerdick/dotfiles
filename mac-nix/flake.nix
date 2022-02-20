{
  description = "Nix Config for Mac by LATB";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    /* nixpkgs.url = "github:nixos/nixpkgs/release-21.11"; */
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    neovim-nightly-overlay,
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

    /* overlay-unstable = final: prev: { */
    /*   unstable = import nixpkgs { */
    /*     inherit system; */
    /*     config = globalPkgsConfig; */
    /*   }; */
    /* }; */
    /* pkgs = import nixpkgs { */
    /*   inherit system; */
    /*   config = globalPkgsConfig; */
    /*   overlays = [ */
    /*     overlay-unstable */
    /*     neovim-nightly-overlay */
    /*   ]; */
    /* }; */
    lib = nixpkgs.lib;

  in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;
    nixosModules.home = import ./home.nix; # attr set or list

    homeConfigurations.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-darwin";
      configuration.imports = [ ./users/bauerdic/home.nix ];
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      extraSpecialArgs = {
        withGUI = false;
        isDesktop = true;
        networkInterface = "xxx";
      };
    };

    m1mac = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
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
