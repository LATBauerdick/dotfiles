/* { config, pkgs, nixpkgs, eww, ... }: */
/* let */
/* in { */
/*   home.packages = with pkgs; [ */
  { pkgs, withGUI }: with pkgs; [
  # these files are meant to be installed in all scenarios
      abduco
      aria
      atuin
      bat
      coreutils
      ctags
      eza
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
      hpack
      htop
      imagemagick
      jq
      lilypond-unstable-with-fonts
      llvm
      lld
      lzop
      mosh
      neofetch
#      neovim-unwrapped
#      neuron-notes
      oh-my-zsh
      oh-my-posh
      pandoc
      pv
      python311Packages.pandoc-xnos
      pandoc-fignos
      pandoc-eqnos
      # python3
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
      zellij
      zoxide
#      kitty

# language support
#      cabal-install
#      cabal2nix

      nodejs_latest
    #    nodePackages_latest.parcel

# tex
      texlive.combined.scheme-full

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
