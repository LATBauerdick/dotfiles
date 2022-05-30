{ config, pkgs, ... }:
let
in {
  home.packages = with pkgs; [
  # add some more, etc
    duf
    du-dust
    entr
    ncdu
    procs
    autossh
    qemu
    lima
    skhd

  ];}
