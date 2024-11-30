# Connectivity info for Linux VM

.PHONY: darwin

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= umini
# umac   xmini x130314
MACNAME ?= m1mac
# btalmac btalintel intelmac rpi lima

darwin:
	darwin-rebuild switch --flake ."#${MACNAME}.${USER}"

home-manager:
	nix build ".#${MACNAME}.${USER}.activationPackage"
	# rm -rf /nix/var/nix/profiles/per-user/${USER}/profile
	./result/activate

switch:
	sudo nixos-rebuild switch --flake ".#${NIXNAME}"

test:
	sudo nixos-rebuild test --flake ".#${NIXNAME}"

update:
	nix flake update

build:
	nix build ".#${MACNAME}.bauerdic.activationPackage"

activate:
	./result/activate

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

