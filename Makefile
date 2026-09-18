# Connectivity info for Linux VM

.PHONY: darwin

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake. Defaults to this machine's
# short hostname (umini umac upro xmini x130314 ...); override with
# NIXNAME=<name> make switch
NIXNAME ?= $(shell hostname -s)
MACNAME ?= m1mac
# btalmac btalintel intelmac rpi lima

# upro (Asahi) reads Apple's peripheral firmware from /boot/vendorfw at eval
# time, which pure flake evaluation cannot see.
NIXOS_FLAGS := $(if $(filter upro,$(NIXNAME)),--impure,)

darwin:
	sudo darwin-rebuild switch --flake ."#${MACNAME}.${USER}"

home-manager:
	nix build ".#${MACNAME}.${USER}.activationPackage"
	# rm -rf /nix/var/nix/profiles/per-user/${USER}/profile
	./result/activate

switch:
	sudo nixos-rebuild switch --flake ".#${NIXNAME}" $(NIXOS_FLAGS)

test:
	sudo nixos-rebuild test --flake ".#${NIXNAME}" $(NIXOS_FLAGS)

update:
	nix flake update

build:
	nix build ".#${MACNAME}.bauerdic.activationPackage"

activate:
	./result/activate

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

