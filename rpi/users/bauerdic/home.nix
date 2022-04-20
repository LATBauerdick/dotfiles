{ config, pkgs, specialArgs, ... }:

#let sources = import ../../nix/sources.nix; in 
let
    inputs.oh-my-posh = "../../../zsh/oh-my-posh";
    pkgs0 = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/12408341763b8f2f0f0a88001d9650313f6371d5.tar.gz";
        sha256 = "sha256:17vgd7a8k0rpmc1lg9lwbla6jr5ks2d35qp7ryp6j4dsy7r8rihw";
    }) {};

    starshipPkg = pkgs0.x86_64-darwin.starship;
    # hacky way of determining which machine I'm running this from
    # inherit (specialArgs) withGUI isDesktop networkInterface localOverlay;
    withGUI = true;
    packages = import ./packages.nix;

in {

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


  home.packages = packages pkgs withGUI;
  /* home.packages = with pkgs; [ */
  /* ]; */

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

  home.file.".tmux.conf".source = ./tmux.conf;

  home.file.".zshrc".source = ./zshrc;
  home.file.".p10k.zsh".source = ./p10k.zsh;
  home.file.".ssh/config".source = ./sshconfig;
  home.file.".oh-my-posh".source = ./oh-my-posh;
  home.file.".config/karabiner/assets".source = ./karabiner-assets;
  home.file.".gitconfig".source = ./gitconfig;

  xdg.enable = true;
  xdg.configFile."nvim".source = ./vim;
  xdg.configFile."kitty".source = ./kitty;

# https://github.com/nix-community/nix-direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.direnv.nix-direnv.enableFlakes = true;
  programs.zsh.enable = true;
}
