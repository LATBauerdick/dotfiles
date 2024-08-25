{
  description = "nix-darwin flake for ltop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
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

      # The platform the configuration will be used on.
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
          "airbuddy"
          # "alfred"
          "arc"
          "arq"
          "bitwarden"
          "brave-browser"
          "calibre"
          "chatgpt"
          "devonthink"
          "discord"
          "eaglefiler"
          "fantastical"
          "firefox"
          "folx"
          #"font-comic-mono"
          #"font-iosevka-nerd-font"
          #"font-jetbrains-mono"
          #"font-lekton-nerd-font"
          #"font-monaspace"
          #"forehead"
          "google-chrome"
          "grandperspective"
          "iterm2"
          "karabiner-elements"
          "keycastr"
          "kicad"
          "kitty"
          "launchcontrol"
          "ltspice"
          #"luna-display"
          #"luna-secondary"
          #"lyn"
          "mactex"
          "marked"
          "mattermost"
          "menuwhere"
          "obsidian"
          "omnigraffle"
          #"openzfs"
          "plex"
          "pdf-expert"
          "private-internet-access"
          "qmk-toolbox"
          "quiet-reader"
          "raindropio"
          "raycast"
          "roon"
          "skype"
          "slack"
          "superduper"
          "tidal"
          # "vinegar"
          # "vivid"
          "vlc"
          "xld"
          "xquartz"
          "zoom"
        ];
        homebrew.brews = [
          "imagemagick"
          "syncthing"
        ];

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MAC-138940
    darwinConfigurations."MAC-138940" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MAC-138940".pkgs;
  };
}
