{
  description = "NixOS systems and Nix Config by LATBauerdick";
# see https://github.com/nix-community/home-manager/blob/master/docs/nix-flakes.adoc

  inputs = {
    utils.url = "github:numtide/flake-utils";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs.url = "/home/bauerdic/nixpkgs"; # sudo git config --global --add safe.directory /home/bauerdic/nixpkgs
    home-manager = {
      # url = "github:nix-community/home-manager/release-22.11";
      # url = "github:nix-community/home-manager";
      url = "/home/bauerdic/home-manager";
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
      config.allowUnfree = true;
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

    nixosConfigurations.rpi   = mkMachine "rpi" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "aarch64-linux";
      user   = "bauerdic";
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
      # inherit pkgs;
      # pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config = { allowUnfree = true; };
      };

      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    intelmac.bauerdic = home-manager.lib.homeManagerConfiguration {
      # pkgs = nixpkgs.legacyPackages.x86_64-darwin;
      pkgs = import nixpkgs {
        system = "x86_64-darwin";
        config = { allowUnfree = true; };
      };
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    intel.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./users/bauerdic/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
        networkInterface = "xxx";
      };
    };

    rpi.bauerdic = home-manager.lib.homeManagerConfiguration {
      # pkgs = nixpkgs.legacyPackages.aarch64-linux;
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };
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
