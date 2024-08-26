{
  description = "nix-darwin flake for ltop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    darwinConfiguration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.git
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the darwinConfiguration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
      system.defaults = {
        dock.autohide = true;
      };

      services.yabai.enable = true;
      services.skhd.enable = true;

        #services.karabiner-elements.enable = true;
      fonts.packages = with pkgs; [
         (nerdfonts.override { fonts = [
            #"FiraCode" 
            #"DroidSansMono" 
            "Iosevka"
            "Lekton"
            ]; })
      ];

      homebrew.enable = true;
      homebrew.casks = [
          "adobe-acrobat-reader"
          "airbuddy"
          "alfred"
          "arc"
          "arq"
          "backuploupe"
          "balenaetcher"
          "bitwarden"
          "bluos-controller"
          "brave-browser"
          "calibre"
          "chatgpt"
          "devonthink"
          "discord"
          "fantastical"
          "firefox"
          "folx"
          "google-chrome"
          "grammarly-desktop"
          "grandperspective"
          "iina"
          "iterm2"
          "karabiner-elements"
          "keycastr"
          "kicad"
          "kitty"
          "launchcontrol"
          "ltspice"
          "mactex"
          "marked"
          "mattermost"
          "mediathekview"
          "menubarx"
          "menuwhere"
          "notchnook"
          "obsidian"
          "omnigraffle"
          "pdf-expert"
          "plex"
          "qmk-toolbox"
          "quiet-reader"
          "raindropio"
          "raycast"
          "roon"
          "skype"
          "slack"
          "superduper"
          "switchresx"
          "tidal"
          "ukelele"
          "vlc"
          "xld"
          "xquartz"
          "zoom"
          #"eaglefiler"
          #"font-comic-mono"
          #"font-iosevka-nerd-font"
          #"font-jetbrains-mono"
          #"font-lekton-nerd-font"
          #"font-monaspace"
          #"forehead"
          #"luna-display"
          #"luna-secondary"
          #"lyn"
          #"openzfs"
          #"private-internet-access"
          #"vinegar"
          #"vivid"
      ];
      homebrew.brews = [
          "imagemagick"
          "syncthing"
      ];

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#lair
    darwinConfigurations."lair" = nix-darwin.lib.darwinSystem {
      modules = [ darwinConfiguration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."lair".pkgs;
  };
}
