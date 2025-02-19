/* { config, pkgs, nixpkgs, eww, ... }: */
/* let */
/* in { */
/*   home.packages = with pkgs; [ */
  { pkgs, withGUI }: with pkgs; [
  # these files are meant to be installed in all scenarios
      abduco
      aria
      ast-grep
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
      lima
      llvm
      lld
      lzop
      mosh
      neofetch
#      neovim-unwrapped
#      neuron-notes
      nmap
      oh-my-zsh
      oh-my-posh
      ollama
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
      texlive.combined.scheme-small

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
