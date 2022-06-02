{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
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

  in utils.lib.eachSystem [ "x86_64-linux" ] (system: rec {
      legacyPackages = import nixpkgs { inherit system; };
  }) // {
    m1mac.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-darwin";
      homeDirectory = "/home/bauerdic";
      username = "bauerdic";
      configuration.imports = [ ./users/bauerdic/home.nix ];
    };
    bauerdic = self.homeConfigurations.bauerdic.activationPackage;
    defaultPackage.aarch64-darwin = self.bauerdic;

  };
}
