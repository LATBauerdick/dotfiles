/* { pkgs, ... }: */

/* { */
/*   home.packages = with pkgs; [ */
  pkgs: with pkgs; [
  # add some more, etc
    autossh
    duf
    du-dust
    entr
    /* lima */
    lilypond-unstable-with-fonts
  # ncdu
    procs
  #  qemu
    sd
    tealdeer
    /* vifs */
    /* ytop */
]
  /* ];} */
