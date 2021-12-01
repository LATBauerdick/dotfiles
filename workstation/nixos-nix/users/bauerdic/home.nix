{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "bauerdic";
  home.homeDirectory = "/home/bauerdic";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #####LATB???? home.stateVersion = "21.05";


  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      sha256 = "0zmg0hj4ivlx3f7a5fgl439fgvdah1v22wczvgvrra3dwwa5p7fr";
    }))
  ];

  home.packages = with pkgs; [
      abduco
      bat
      ctags
      fd
      fzf
      dtach
      dvtm
      gawk
      git
      git-crypt
      gnupg
      pinentry-qt
      htop
#      hub
#      imagemagick
      jq
      kitty
#      librsvg
#      lzop
#      mdcat
      neovim-unwrapped

      pandoc
      ripgrep
      silver-searcher
      tmux
      thefuck
      tree
      wget
      zoxide

# language support
      cabal-install
      cabal2nix
  
      texlive.combined.scheme-full
  ];
#    programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";

# Tex installation
  fonts.fontconfig.enable = true;

  #------------------------------------------------------------------
  # Env vars and dotfiles
  #--------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "less -FirSwX";
  };

  home.file.".tmux.conf".source = ../../../../tmux/tmux.conf;

  home.file.".zshrc".source = ../../../../zsh/zshrc;
  home.file.".p10k.zsh".source = ../../../../zsh/p10k.zsh;

  xdg.enable = true;
  xdg.configFile."nvim".source = ../../../../vim;
  xdg.configFile."kitty".source = ../../../../kitty;

# https://github.com/nix-community/nix-direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.nix-direnv.enableFlakes = true;
  programs.zsh.enable = true;
}
