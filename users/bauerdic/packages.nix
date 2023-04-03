/* { config, pkgs, nixpkgs, eww, ... }: */
/* let */
/* in { */
/*   home.packages = with pkgs; [ */
  { pkgs, withGUI }: with pkgs; [
  # these files are meant to be installed in all scenarios
      abduco
      bat
      coreutils
      ctags
      exa
      exiftool
      fd
      fzf
      dtach
      dvtm
      # emanote
      gawk
      git
      git-crypt
      git-lfs
      gnupg
      gnumake
      helix
      htop
      imagemagick
      jq
      llvm
      lzop
      mosh
      neofetch
      neovim-unwrapped
#      neuron-notes
      oh-my-zsh
      pandoc
      pinentry-qt
      pv
      # python310Packages.pandoc-xnos
      # python3
      # qemu
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
#      texlive.combined.scheme-full


  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      ddcutil # monitor brightness
      mutt-with-sidebar
      bitwarden-cli
  ] ++ pkgs.lib.optionals withGUI [
      kitty
      bitwarden
      obsidian
      skypeforlinux
      slack
      thunderbird
      vlc
      zoom-us
  ]
  /* ];} */
