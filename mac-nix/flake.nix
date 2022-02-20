{
  description = "Nix Config for Mac by LATB";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, home-manager-unstable, ... }@inputs:
  let
    nixpkgs = nixpkgs-unstable;
    home-manager = home-manager-unstable;
    lib = nixpkgs.lib;

  in {
    homeManagerConfigurationsM1X = {
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
