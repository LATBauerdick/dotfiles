
# The name of the nixosConfiguration in the flake
MACNAME ?= m1mac

macall:
	nix flake lock
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure ".#${MACNAME}.bauerdic.activationPackage"
	rm -rf /nix/var/nix/profiles/per-user/${USER}/profile
	./result/activate
	nix profile install github:latbauerdick/oh-my-posh

update:
	nix flake lock

