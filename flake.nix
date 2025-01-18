{
  description = "NixOS systems and Nix Config by LATBauerdick";
# see https://github.com/nix-community/home-manager/blob/master/docs/nix-flakes.adoc

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixpkgs.url = "/home/bauerdic/nixpkgs"; # sudo git config --global --add safe.directory /home/bauerdic/nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-24.11";
      # url = "/home/bauerdic/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    limainit.url = "github:msgilligan/nixos-lima/msgilligan-main";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    utils,
    nix-darwin,
    nix-homebrew,
    nixvim,
    limainit,
    ... }@inputs:
  let
    globalPkgsConfig = {
      allowUnfree = true;
    };
    localOverlay = _: _: { };
    overlays = import ./overlays.nix ++ [
##      inputs.neovim-nightly-overlay.overlays.default
    ];
    # overlay-roon = system: prev: final: {
      # roon-bridge = roon.packages.${system}.roon-bridge;
    # };
    pkgsForSystem = system: import nixpkgs {
      # overlay = [ localOverlay ];
      inherit system;
      overlays = [  # ( overlay-ohmyposh system )
                    # ( overlay-roon system )
                 ];
      config.allowUnfree = true;
    };
    darwinConfig = ./darwin/darwin.nix;
    mkMachine = name: { nixpkgs, home-manager, system, user, extraSpecialArgs ? {} }: nixpkgs.lib.nixosSystem rec {
      inherit system;
      modules = [
        ./hardware/${name}.nix
        ./machines/${name}.nix
        ./users/${user}/${user}.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./users/user/home.nix {
            user = user;
            dir = "/home/${user}";
          };
          home-manager.extraSpecialArgs = extraSpecialArgs;
        }
        { nixpkgs.overlays = overlays; }
      ];
    };

    mkDarwin = { nixpkgs, home-manager, system, user, dir, extraSpecialArgs ? {} }:  nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        darwinConfig
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            # enableRosetta = true;
            user=user;
            autoMigrate=true;
          };
        }
        home-manager.darwinModules.home-manager {
          home-manager.users.${user} =
              import ./users/user/home.nix { user=user; dir=dir; };
          home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
        # to fix some supposed bug in home-manager
          users.users."${user}".home = dir;
        }
      # { nixpkgs.overlays = import ./overlays.nix ++ [ ]; }
      ];
    };


  in utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    # non-system suffixed items should go here
    overlay = localOverlay;

    nixosConfigurations.lima = nixpkgs.lib.nixosSystem {
# nixos-rebuild switch --flake .#lima --use-remote-sudo
      # Change this to "x86_64-linux" if necessary
      system = "aarch64-linux";
      # Pass the `limainit` input along with the default module system parameters
      specialArgs = { inherit limainit; };
      modules = [
        ./hardware/lima.nix
        ./machines/lima.nix
        ./users/latb/latb.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.latb = import ./users/user/home.nix {
            user = "latb";
            dir = "/home/latb.linux";
          };
          home-manager.extraSpecialArgs = { # pass arguments
		  withGUI = false;
		  isDesktop = true;
	  };
        }
        { nixpkgs.overlays = overlays; }
      ];
    };

    nixosConfigurations.fmini = mkMachine "fmini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    nixosConfigurations.fu = mkMachine "fu" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    nixosConfigurations.umini = mkMachine "umini" {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    nixosConfigurations.ude = mkMachine "ude" {
      nixpkgs = nixpkgs;  
      home-manager = home-manager;
      system = "x86_64-linux";
      user   = "latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
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

    m1mac.latb = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsForSystem "aarch64-darwin";
      modules = [ ./users/user/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    rpi.bauerdic = home-manager.lib.homeManagerConfiguration {
      # pkgs = nixpkgs.legacyPackages.aarch64-linux;
      pkgs = pkgsForSystem "aarch64-linux";
      modules = [ ./users/user/home.nix ];
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    intel.bauerdic = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsForSystem "x86_64-linux";
      modules = [ ./users/user/home.nix ];
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
      modules = [ ./users/user/home.nix ];
    };

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#lair

    darwinConfigurations.m1mac.bauerdic = mkDarwin {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "aarch64-darwin";
      user   = "bauerdic";
      dir   =  "/home/bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
 
    darwinConfigurations.m1mac.latb = mkDarwin {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "aarch64-darwin";
      user   = "latb";
      dir   =  "/home/latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
 
    darwinConfigurations.btalmac = mkDarwin {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "aarch64-darwin";
      user   = "btal";
      dir    = "/Users/btal";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    darwinConfigurations.intelmac.bauerdic =  mkDarwin {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-darwin";
      user   = "bauerdic";
      dir    = "/home/bauerdic";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };
    darwinConfigurations.intelmac.latb = mkDarwin {
      nixpkgs = nixpkgs;
      home-manager = home-manager;
      system = "x86_64-darwin";
      user   = "latb";
      dir    = "/home/latb";
      extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = true;
      };
    };

    # Expose the package set, including overlays, for convenience.
    # darwinPackages = self.darwinConfigurations."lair".pkgs;
  };
}
