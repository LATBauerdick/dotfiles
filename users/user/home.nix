{ user ? "bauerdic", dir ? "/home/bauerdic"  } : { config, pkgs,  ... }:

let
    # hacky way of determining which machine I'm running this from
    # inherit (specialArgs) withGUI isDesktop networkInterface localOverlay;
    myPackages = import ./packages.nix { inherit pkgs; withGUI = specialArgs.withGUI;  };
    extraPackages = import ./extraPackages.nix;
    specialArgs = {
        withGUI = false;
        isDesktop = true;
    };

in {

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = user;
  home.homeDirectory = dir;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home.packages =  [ ] ++ myPackages ++ ( extraPackages pkgs );

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

  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };
  };

  home.file.".tmux.conf".source = ./tmux/tmux.conf;

  home.file.".zshrc".source = ./zsh/zshrc;
  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;
  home.file.".ssh/config".source = ./ssh/sshconfig;
  home.file.".oh-my-posh".source = ./zsh/oh-my-posh;
  home.file.".config/karabiner/assets".source = ./karabiner/assets;
  home.file.".gitconfig".source = ./git/gitconfig;
  home.file.".config/yabai/yabairc".source = ./yabai/yabairc;
  home.file.".config/skhd/skhdrc".source = ./yabai/skhdrc;
  home.file.".config/limelight/limelightrc".source = ./yabai/limelightrc;

  xdg.enable = true;
  xdg.configFile."nvim/lua".source = ./vim/lua;
  xdg.configFile."nvim/init.lua".source = ./vim/init.lua;

  xdg.configFile."aerospace/aerospace.toml".source = ./aerospace/aerospace.toml;

  #programs.nixvim = {
  #  enable = true;
  #  globals.mapleader = " ";
  #  globals.maplocalleader = " ";
  #  opts = {
  #    relativenumber = true;
  #    ignorecase = true;
  #    incsearch = true;
  #    textwidth = 80;
  #    numberwidth = 5;
  #  };
  #  colorschemes.catppuccin.enable = true;
  #  #colorschemes.everforest.settings = {
  #  #    background = "hard";
  #  #    dim_inactive_windows = 1;
  #  #};
  #  plugins.lualine.enable = true;
  #  plugins.nix.enable = true;

  #  plugins.treesitter.enable = true;

  #  plugins.telescope.enable = true;

  #  plugins.harpoon = {
  #    enable = true;
  #    keymaps.addFile = "<leader>a";
  #  };

  #  plugins.lsp = {
  #    keymaps = {
  #      silent = true;
  #      diagnostic = {
  #        "<leader>k" = "goto_prev";
  #        "<leader>j" = "goto_next";
  #      };

  #      lspBuf = {
  #        gd = "definition";
  #        K  = "hover";
  #      };
  #    };
  #  };
  #};





  # xdg.configFile."nvim".source = ./vim;
  # xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/myTheme.conf".source = ./kitty/myTheme.conf;

  programs.kitty.enable = true;
  # programs.kitty.font.name = "Iosevka Nerd Font";
  # programs.kitty.font.size = 14.0;
  # programs.kitty.theme = "Solarized Light";

  xdg.configFile."awesome".source = ./awesome;

  xdg.configFile."amethyst".source = ./amethyst;

# https://github.com/nix-community/nix-direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.direnv.nix-direnv.enableFlakes = true;
  programs.zsh.enable = true;


#  xdg.configFile."alacritty".source=mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dot/config/alacritty"



}
