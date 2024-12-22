{
  description = "NixOS System Config by LATB";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    lib = nixpkgs.lib;
    user = "bauerdic";
    extraSpecialArgs = { # pass arguments
        withGUI = false;
        isDesktop = false;
    };
  in {
    homeManagerConfigurations = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [
        ./users/${user}/${user}.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import ./users/user/home.nix {
            user = user;
            dir = "/home/${user}";
          };
          home-manager.extraSpecialArgs = extraSpecialArgs;
          home.stateVersion = "20.09";
        }
        /* { nixpkgs.overlays = import ./overlays.nix ++ [ ]; } */
        ];
      };
    };

    nixosConfigurations = {
      nix-latb = lib.nixosSystem {
        inherit system;

        modules = [
          ./system/configuration.nix
        ];
      };
    };
  };
}
