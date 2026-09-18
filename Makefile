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

# ude only: run the rebuild in its own transient systemd unit, detached from
# the ssh session. With Tailscale SSH the session is a child of
# tailscaled.service, so a switch that restarts tailscaled kills the shell AND
# the rebuild running in it — seen on ude 2026-09-17 (units left stopped).
# ude has no console to fall back to; the other hosts do, so they run plainly.
# --pty/--pipe keep the output on the terminal, --wait keeps make blocking,
# --same-dir keeps the flake reference resolvable, --collect drops the unit
# afterwards. SUDO_UID/SUDO_USER are forwarded because libgit2 (nix's flake
# fetcher) only lets root read a repository owned by someone else when they
# match the owner.
DETACHED_HOSTS := ude
DETACHED := $(if $(filter $(DETACHED_HOSTS),$(NIXNAME)),systemd-run --unit=nixos-rebuild-$(NIXNAME) --pty --pipe --wait --collect --same-dir --setenv=PATH=$$PATH --setenv=SUDO_UID --setenv=SUDO_USER --setenv=SUDO_GID --quiet,)
# (no commas inside $(if …) — make would read them as argument separators)
DETACHED_HINT := $(if $(DETACHED),@echo "detached rebuild - if this ssh session drops: reconnect and run   journalctl -fu nixos-rebuild-$(NIXNAME)",@:)

darwin:
	sudo darwin-rebuild switch --flake ."#${MACNAME}.${USER}"

home-manager:
	nix build ".#${MACNAME}.${USER}.activationPackage"
	# rm -rf /nix/var/nix/profiles/per-user/${USER}/profile
	./result/activate

switch:
	$(DETACHED_HINT)
	sudo $(DETACHED) nixos-rebuild switch --flake ".#${NIXNAME}" $(NIXOS_FLAGS)

test:
	$(DETACHED_HINT)
	sudo $(DETACHED) nixos-rebuild test --flake ".#${NIXNAME}" $(NIXOS_FLAGS)

update:
	nix flake update

build:
	nix build ".#${MACNAME}.bauerdic.activationPackage"

activate:
	./result/activate

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

