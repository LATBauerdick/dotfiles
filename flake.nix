{
  description = "NixOS systems and Nix Config by LATBauerdick";
# see https://github.com/nix-community/home-manager/blob/master/docs/nix-flakes.adoc

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    # nixpkgs.url = "/home/bauerdic/nixpkgs"; # sudo git config --global --add safe.directory /home/bauerdic/nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # url = "/home/bauerdic/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ohmyposh = { url = "github:latbauerdick/oh-my-posh"; };
    # roon = { url = "/home/bauerdic/nixpkgs/pkgs/servers/roon-bridge"; };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    utils,
    ohmyposh,
    # roon,
    ... }@inputs:
  let

    globalPkgsConfig = {
      allowUnfree = true;
    };
    localOverlay = _: _: { };
    overlay-ohmyposh = system: prev: final: {
      oh-my-posh = ohmyposh.packages.${system}.oh-my-posh;
    };
    # overlay-roon = system: prev: final: {
      # roon-bridge = roon.packages.${system}.roon-bridge;
    # };
    pkgsForSystem = system: import nixpkgs {
      # overlay = [ localOverlay ];
      inherit system;
      overlays = [  ( overlay-ohmyposh system )
                    # ( overlay-roon system )
                 ];
      config.allowUnfree = true;
    };

    mkMachine = name: { nixpkgs, home-manager, system, user, extraSpecialArgs ? {} }: nixpkgs.lib.nixosSystem rec {
      inherit system;
      modules = [
        ./hardware/${name}.nix
        ./machines/${name}.nix
        ./users/${user}/user.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./users/${user}/home.nix;
          home-manager.extraSpecialArgs = extraSpecialArgs;
        }
        { nixpkgs.overlays = import ./overlays.nix ++ [ ]; }
      ];
    };

  in utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;

    nixosConfigurations.xmini = mkMachine "xmini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    nixosConfigurations.x130314 = mkMachine "x130314" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    nixosConfigurations.umini = mkMachine "umini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    nixosConfigurations.usrv = mkMachine "usrv" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "bauerdic";
    };

    nixosConfigurations.rpi   = mkMachine "rpi" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "aarch64-linux";
      user   = "bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    homeConfigurations.bauerdic = home-manager.lib.homeManagerConfiguration {
      # inherit pkgs;
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    m1mac.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsForSystem "aarch64-darwin";
      # pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    intelmac.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsForSystem "x86_64-darwin";
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    rpi.bauerdic = home-manager.lib.homeManagerConfiguration {
      # pkgs = nixpkgs.legacyPackages.aarch64-linux;
      pkgs = pkgsForSystem "aarch64-linux";
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    intel.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsForSystem "x86_64-linux";
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    bauerdic = self.homeConfigurations.bauerdic.activationPackage;
    defaultPackage.aarch64-darwin = self.bauerdic;

    lima.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };
      modules = [ ./users/bauerdic/home.nix ];
    };
  };
}
