#!/bin/sh
# home-manager switch -f ./users/bauerdic/home.nix
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#homeManagerConfigurations.bauerdic.activationPackage
./result/activate
