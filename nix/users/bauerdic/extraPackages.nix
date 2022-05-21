{ config, pkgs, ... }:
let
in {
  home.packages = with pkgs; [
  # add some more, etc
    duf
    du-dust
    ncdu
    procs

  ];}
