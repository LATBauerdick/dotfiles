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

  in {
    homeManagerConfigurations = {
      bauerdic = home-manager.lib.homeManagerConfiguration {
#        inherit system pkgs;
        pkgs = nixpkgs.legacyPackages.${system};
	modules = [
          ./users/bauerdic/home.nix
	  {
	    home = {
              username = "bauerdic";
              homeDirectory = "/home/bauerdic";
              stateVersion = "22.05";
            };
          }
	];
#        username = "bauerdic";
#        homeDirectory = "/home/bauerdic";
#        configuration = {
#          imports = [
#            ./users/bauerdic/home.nix
#          ];
#        };
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
