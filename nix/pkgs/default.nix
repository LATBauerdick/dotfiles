{
  pkgs ? import <nixpkgs> {}
}:

with pkgs;

let
  packages = rec {
    oh-my-posh = callPackage ./oh-my-posh {};

    inherit pkgs;
  };
in
  packages
