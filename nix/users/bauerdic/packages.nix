{ config, pkgs, nixpkgs, eww, ... }:
let
in {
  home.packages = with pkgs; [
  # these files are meant to be installed in all scenarios
      nix
      abduco
      bat
      coreutils
      ctags
      exa
      exiftool
      fd
      fzf
      dtach
      gawk
      git
      git-crypt
      git-lfs
      gnupg
      gnumake
      htop
      imagemagick
      jq
      mosh
      neofetch
      neovim-unwrapped
      neuron-notes
      oh-my-zsh
      pinentry-qt
      pandoc
      python
      qemu
      ranger
      ripgrep
      silver-searcher
      tmux
      tree
      unzip
      unrar
      wget
      xz
      zoxide

# language support
#      cabal-install
#      cabal2nix

# tex
#####      texlive.combined.scheme-full


  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      ddcutil # monitor brightness
      mutt-with-sidebar
      bitwarden-cli
      sanoid
###] ++ pkgs.lib.optionals withGUI [
      kitty
      bitwarden
      obsidian
      skypeforlinux
      slack
      thunderbird
      vlc
      zoom-us
  ];
}
