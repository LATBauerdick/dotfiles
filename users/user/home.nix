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
  home.file.".oh-my-posh".source = ./zsh/oh-my-posh;
  home.file.".ssh/config".source = ./ssh/sshconfig;
  home.file.".gitconfig".source = ./git/gitconfig;
  home.file.".editorconfig".source = ./vim/editorconfig;

  programs.neovim = {
    enable = true;
  };

  xdg.enable = true;
  xdg.configFile."nvim/lua".source = ./vim/lua;
  xdg.configFile."nvim/after".source = ./vim/after;
  xdg.configFile."nvim/init.lua".source = ./vim/init.lua;

  xdg.configFile."aerospace/myAerospace.toml".source = ./aerospace/myAerospace.toml;

  xdg.configFile."borders/bordersrc".source = ./borders/bordersrc;
  xdg.configFile."yabai/yabairc".source = ./yabai/yabairc;
  xdg.configFile."skhd/skhdrc".source = ./yabai/skhdrc;
  xdg.configFile."limelight/limelightrc".source = ./yabai/limelightrc;
  xdg.configFile."awesome".source = ./awesome;
  xdg.configFile."amethyst".source = ./amethyst;
  xdg.configFile."karabiner/assets".source = ./karabiner/assets;

  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/lightTheme.conf".source = ./kitty/lightTheme.conf;
  xdg.configFile."kitty/darkTheme.conf".source = ./kitty/darkTheme.conf;

  programs.kitty.enable = true;
  # programs.kitty.font.name = "Iosevka Nerd Font";
  # programs.kitty.font.size = 14.0;
  # programs.kitty.theme = "Solarized Light";

# https://github.com/nix-community/nix-direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.direnv.nix-direnv.enableFlakes = true;
  programs.zsh.enable = true;


#  xdg.configFile."alacritty".source=mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dot/config/alacritty"



}
