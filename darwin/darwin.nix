 { pkgs, config, ... }:
  let
    myPackages = import ./darwinPackages.nix { inherit pkgs; };
    # myCasks = import ./darwinCasks.nix;
    # myBrews = import ./darwinBrews.nix;
    myMasApps = import ./darwinMasApps.nix;
  in
  {
    environment.systemPackages = myPackages.systemPackages;
    fonts.packages = myPackages.fontsPackages;

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
    ids.gids.nixbld = 350;

    system.primaryUser = "bauerdic"; #builtins.getEnv "USER";

    nixpkgs.config.allowUnfree = true;

    # security.pam.enableSudoTouchIdAuth = true;
    system.defaults = {
      dock.autohide = true;
      dock.largesize = 128;
      dock.magnification = true;
      dock.orientation = "bottom";
      dock.persistent-apps = [
        "${pkgs.obsidian}/Applications/Obsidian.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Launchpad.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Safari.app"
      ];
      dock.expose-group-apps = true;
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";

      };
      spaces.spans-displays = true;
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
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

      NSWindowShouldDragOnGesture = true;
    };

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
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


   services.yabai.enable = false;
   services.skhd.enable = false;

      #services.karabiner-elements.enable = true;
   # homebrew = {
   #   enable = true;
   #   casks = myCasks;
   #   brews = myBrews;
   #   # masApps = myMasApps;
   #   onActivation.cleanup = "zap";
   #   onActivation.autoUpdate = true;
   #   onActivation.upgrade = true;
   # };
#   system.activationScripts.postUserActivation.text = ''
#      # Following line should allow us to avoid a logout/login cycle
#      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
#  '';

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
    # Set up applications.
    echo "setting up /Applications..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
    while read -r src; do
      app_name=$(basename "$src")
      echo "copying $src" >&2
      ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    done
  '';

}

