 { pkgs, ... }:
    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
  {
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
  # system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;

   # nixpkgs.config.allowUnfree = true;

    security.pam.enableSudoTouchIdAuth = true;
    system.defaults = {
      dock.autohide = true;
      dock.largesize = 128;
      dock.magnification = true;
      dock.orientation = "left";
    };
    system.defaults.NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;

      # 120, 90, 60, 30, 12, 6, 2
      KeyRepeat = 2;

      # 120, 94, 68, 35, 25, 15
      InitialKeyRepeat = 15;

      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;
    };

    system.defaults.trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    system.defaults.finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = false;
      FXEnableExtensionChangeWarning = false;

    };
    system.defaults.CustomUserPreferences = {
      NSGlobalDomain = {
        # Add a context menu item for showing the Web Inspector in web views
        WebKitDeveloperExtras = true;
      };
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.screensaver" = {
        # Require password immediately after sleep or screen saver begins
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
      "com.apple.screencapture" = {
        location = "~/Desktop";
        type = "png";
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      "com.apple.print.PrintingPrefs" = {
        # Automatically quit printer app once the print jobs complete
        "Quit When Finished" = true;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Download newly available updates in background
        AutomaticDownload = 1;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      # Turn on app auto-update
      "com.apple.commerce".AutoUpdate = true;
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
          "JetBrainsMono"
          ]; })
    ];

    homebrew.enable = true;
    homebrew.casks = [
        "adobe-acrobat-reader"
        "airbuddy"
        "alfred"
        "arc"
     # "arq"
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
     # "karabiner-elements"
        "keycastr"
     #   "kicad"
        "kitty"
        "launchcontrol"
     #   "ltspice"
        "mactex"
        "marked"
        "mattermost"
        "mediathekview"
        "menubarx"
        "menuwhere"
        "musescore"
       # "notchnook"
        "obsidian"
        "omnigraffle"
        "pdf-expert"
        "plex"
        "qmk-toolbox"
        "quicksilver"
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
    homebrew.masApps = {
     # "Drafts" = 1435957248;
      "Reeder" = 1529448980;
    };
    system.activationScripts.postUserActivation.text = ''
  # Following line should allow us to avoid a logout/login cycle
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
'';

}

