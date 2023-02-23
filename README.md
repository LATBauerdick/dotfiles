# dotfiles
my dotfiles

based on nix flakes and home manager; use see `Makefile`; e.g.

```
NIXPKGS_ALLOW_UNFREE=1 nix build --impure "github:latbauerdick/dotfiles#m1mac.bauerdic.activationPackage"
./result/activate
```
and
```
sudo NIXNAME=xmini NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild --impure switch --flake “GitHub:latbauerdick/dotfiles#${NIXNAME}"
```
