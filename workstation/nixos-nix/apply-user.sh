#!/bin/sh
# home-manager switch -f ./users/bauerdic/home.nix
nix build .#homeManagerConfigurations.bauerdic.activationPackage
./result/activate
