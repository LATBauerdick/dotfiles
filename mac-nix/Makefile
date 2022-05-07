# Connectivity info for Linux VM

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
NIXNAME ?= umini

# The name of the nixosConfiguration in the flake
NIXM1X ?= m1mac.bauerdic.activationPackage
NIXMAC ?= homeManagerConfigurationsMac.bauerdic.activationPackage
NIXLIMA ?= homeManagerConfigurationsLima.bauerdic.activationPackage

macall:
	nix flake lock
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure ".#${NIXM1X}"
	./result/activate

macintel:
	nix flake lock
	nix build ".#${NIXMAC}"
	./result/activate

switch:
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"

test:
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#${NIXNAME}"

update:
	nix flake lock

macbuild:
	nix build ".#${NIXMAC}"

limabuild:
	nix build ".#${NIXLIMA}"

activate:
	./result/activate

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

