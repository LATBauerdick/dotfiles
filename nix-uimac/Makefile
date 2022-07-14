
# The name of the nixosConfiguration in the flake
NIXNAME ?= uimac

switch:
	nix flake lock
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"

test:
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#${NIXNAME}"

update:
	nix flake lock

