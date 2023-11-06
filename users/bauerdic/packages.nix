/* { config, pkgs, nixpkgs, eww, ... }: */
/* let */
/* in { */
/*   home.packages = with pkgs; [ */
  { pkgs, withGUI }: with pkgs; [
  # these files are meant to be installed in all scenarios
      abduco
      aria
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
      oh-my-posh
      pandoc
      pinentry-qt
      pv
      python311Packages.pandoc-xnos
      pandoc-fignos
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
      kitty

# language support
#      cabal-install
#      cabal2nix

    nodejs_latest
    nodePackages_latest.parcel

# tex
#      texlive.combined.scheme-full


  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      ddcutil # monitor brightness
      mutt-with-sidebar
      bitwarden-cli
  ] ++ pkgs.lib.optionals withGUI [
      # kitty
      bitwarden
      obsidian
      skypeforlinux
      slack
      thunderbird
      vlc
      zoom-us
  ]
  /* ];} */
