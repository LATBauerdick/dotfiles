pkgs: withGUI: with pkgs; [
  # these files are meant to be installed in all scenarios
      nix
      abduco
      bat
      coreutils
      ctags
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
      neofetch
      neovim-unwrapped
      neuron-notes
      /* oh-my-posh */
      oh-my-zsh
      pinentry-qt
      pandoc
      python
      qemu
      ripgrep
      silver-searcher
      tmux
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
]

