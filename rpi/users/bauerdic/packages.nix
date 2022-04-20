pkgs: withGUI: with pkgs; [
  # these files are meant to be installed in all scenarios
      abduco
      bat
#      colima
      coreutils
      ctags
#      exiftool
      fd
      fzf
      dtach
      gawk
#      gcc
      git
      git-crypt
      git-lfs
      gnupg
      gnumake
      htop
      imagemagick
      jq
      kitty
#      lima
      neofetch
      neovim-unwrapped
      neuron-notes
#      oh-my-posh
      pinentry-qt
      pandoc
      python
#      qemu
      ripgrep
      silver-searcher
      tmux
#      thefuck
      tree
      unzip
      wget
      xz
      zoxide

# language support
#      cabal-install
#      cabal2nix

# tex
#####      texlive.combined.scheme-full


] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      bitwarden-cli
] ++ pkgs.lib.optionals withGUI [
]

