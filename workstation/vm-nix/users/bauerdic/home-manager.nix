{ config, lib, pkgs, ... }:

let sources = import ../../nix/sources.nix;
    # texlive = import ./texlive.nix { inherit pkgs; };

in {
  xdg.enable = true;

  home.packages = with pkgs; [

      abduco
      bat
      ctags
      fd
      fzf
      dtach
      gawk
      gcc
      git
      git-crypt
      git-lfs
      gnupg
      gnumake
      pinentry-qt
      htop
      jq
      kitty
      lima
      neofetch
      neovim-unwrapped

      pandoc
      qemu
      ripgrep
      silver-searcher
      tmux
#      thefuck
      tree
      wget
      zoxide

# language support
      cabal-install
      cabal2nix
# apps
      firefox
      okular

      rofi
      watch

# tex
#      texlive.combined.scheme-full
#      texlive.mytexlive

  ];
#    programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";

#  fonts for Tex installation
#  fonts.fontconfig.enable = true;

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "less -FirSwX";
  };

  home.file.".inputrc".source = ./inputrc;
  home.file.".tmux.conf".source = ../../../../tmux/tmux.conf;

  home.file.".zshrc".source = ../../../../zsh/zshrc;
  home.file.".p10k.zsh".source = ../../../../zsh/p10k.zsh;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;

  xdg.configFile."nvim".source = ../../../../vim;
#  xdg.configFile."nvim".target = "../.dotfiles/vim";

  xdg.configFile."kitty".source = ../../../../kitty;

  # tree-sitter parsers
#  xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
#  xdg.configFile."nvim/queries/proto/folds.scm".source =
#    "${sources.tree-sitter-proto}/queries/folds.scm";
#  xdg.configFile."nvim/queries/proto/highlights.scm".source =
#    "${sources.tree-sitter-proto}/queries/highlights.scm";
#  xdg.configFile."nvim/queries/proto/textobjects.scm".source =
#    ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.git = {
    enable = true;
    userName = "LATBauerdick";
    userEmail = "github@bauerdick.org";
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    };
    extraConfig = {
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "latbauerdick";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

#  programs.tmux = {
#    enable = true;
#    terminal = "xterm-256color";
#    shortcut = "l";
#    secureSocket = false;
#
#    extraConfig = ''
#      set -ga terminal-overrides ",*256col*:Tc"
#
#      set -g @dracula-show-battery false
#      set -g @dracula-show-network false
#      set -g @dracula-show-weather false
#
#      bind -n C-k send-keys "clear"\; send-keys "Enter"
#
#      run-shell ${sources.tmux-pain-control}/pain_control.tmux
#      run-shell ${sources.tmux-dracula}/dracula.tmux
#    '';
#  };

#  programs.kitty = {
#    enable = true;
#    extraConfig = builtins.readFile ./kitty;
#  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

#  programs.neovim = {
#    enable = true;
#    package = pkgs.neovim-nightly;
#
#    plugins = with pkgs; [
#      customVim.vim-fugitive
#      customVim.vim-misc
#      customVim.vim-tla
#      customVim.pigeon
#      customVim.AfterColors
#
#      customVim.vim-nord
#      customVim.nvim-lspconfig
#      customVim.nvim-treesitter
#      customVim.nvim-treesitter-playground
#      customVim.nvim-treesitter-textobjects
#
#      vimPlugins.ctrlp
#      vimPlugins.vim-airline
#      vimPlugins.vim-airline-themes
#      vimPlugins.vim-eunuch
#      vimPlugins.vim-gitgutter
#
#      vimPlugins.vim-markdown
#      vimPlugins.vim-nix
#      vimPlugins.typescript-vim
#    ];
#
#    extraConfig = (import ./vim-config.nix) { inherit sources; };
#  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  xsession.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };
}
