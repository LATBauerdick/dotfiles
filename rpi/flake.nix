{
  description = "NixOS systems and Nix Config by LATBauerdick";

  inputs = {
    utils.url = "github:numtide/flake-utils";
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

    lib = nixpkgs.lib;
  in utils.lib.eachSystem [ "aarch64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;


    rpi.bauerdic = home-manager.lib.homeManagerConfiguration {
      system = "aarch64-linux";
      username = "bauerdic";
      homeDirectory = "/home/bauerdic";
      configuration.imports = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
        networkInterface = "xxx";
      };
    };
  };
}
