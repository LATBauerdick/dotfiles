# Connectivity info for Linux VM

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
NIXNAME ?= umini
# umac   xmini
MACNAME ?= m1mac
# intelmac  lima

macall:
	nix flake lock
	nix build ".#${MACNAME}.bauerdic.activationPackage"
	rm -rf /nix/var/nix/profiles/per-user/${USER}/profile
	./result/activate
	nix profile install github:latbauerdick/oh-my-posh

switch:
	sudo nixos-rebuild switch --flake ".#${NIXNAME}"

test:
	sudo nixos-rebuild test --flake ".#${NIXNAME}"

update:
	nix flake lock

build:
	nix build ".#${MACNAME}.bauerdic.activationPackage"

activate:
	./result/activate

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

