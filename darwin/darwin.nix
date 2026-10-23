 { primaryUser ? "latb" } : { pkgs, config, ... }:
  let
    myPackages = import ./darwinPackages.nix { inherit pkgs; };
    myCasks = import ./darwinCasks.nix;
    myBrews = import ./darwinBrews.nix;
    # myMasApps = import ./darwinMasApps.nix;
  in
  {
    environment.systemPackages = myPackages.systemPackages;
    fonts.packages = myPackages.fontsPackages;

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";
    # Proper list syntax renders as "trusted-users = root <user>" in nix.conf.
    # (fpro's Sep-10 build carried a malformed literal "[ \"root\" \"latb\"]",
    # which made latb untrusted and triggered restricted-setting warnings.)
    nix.settings.trusted-users = [ primaryUser ]; # module default already adds root

    # SMB client: no packet signing — noticeably faster to umini, whose shares
    # are reachable from the LAN and the tailnet only (2026-10-11). The hash
    # lets nix-darwin take over lmini's hand-made copy of the same text.
    environment.etc."nsmb.conf" = {
      text = ''
        [default]
        signing_required=no
      '';
      knownSha256Hashes = [ "992344f015898df5cd839f795bda683b91eb21830bf09da66092f6d8f1f78ddd" ];
    };

    # herdr server owned by launchd in the GUI login (2026-10-13). Otherwise the
    # first client after a reboot or `herdr server stop` starts it — and when
    # that is a remote `herdr --remote` over Tailscale SSH, the server and every
    # pane inherit the SSH session's TCC context: Day One writes denied,
    # DEVONthink Automation prompts again (lmini, 10-11 and 10-13). Under
    # launchd, TCC attributes to the herdr binary itself — the one already
    # granted Full Disk Access. KeepAlive: `herdr server stop` now means
    # restart in the right context. After `brew upgrade herdr`, re-grant FDA
    # (ad-hoc signed) and `launchctl kickstart -k gui/$UID/local.herdr.server`.
    # The remote side of the race is closed in home.nix (zsh envExtra).
    launchd.user.agents.herdr-server.serviceConfig = {
      Label = "local.herdr.server";
      ProgramArguments = [ "/opt/homebrew/bin/herdr" "server" ];
      RunAtLoad = true;
      KeepAlive = true;
      LimitLoadToSessionType = "Aqua";
      ProcessType = "Interactive";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        LANG = "en_US.UTF-8";
      };
    };

    # Create /etc/zshrc that loads the nix-darwin environment.
    programs.zsh.enable = true;  # default shell on catalina
    # programs.fish.enable = true;

    # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
    ids.gids.nixbld = 350;

    system.primaryUser = primaryUser;

    nixpkgs.config.allowUnfree = true;

    # security.pam.enableSudoTouchIdAuth = true;
    system.defaults = {
      dock.autohide = true;
      dock.largesize = 128;
      dock.magnification = true;
      dock.orientation = "bottom";
      dock.persistent-apps = [
        # "/System/Applications/Calendar.app"
        # "/System/Applications/Mail.app"
        # "/System/Applications/Safari.app"
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
      # macOS native tiling instead of a tiling WM (trial on ftop from
      # 2026-10-23): Fill (fn-ctrl-F) keeps a normal window, so others can sit
      # in front; margins are on/off only, their width is fixed by macOS
      WindowManager = {
        EnableTiledWindowMargins = true;
        EnableTilingByEdgeDrag = true;
        EnableTilingOptionAccelerator = true;
      };
      # double-click a title bar = Fill (no nix-darwin option for it)
      CustomUserPreferences.NSGlobalDomain.AppleActionOnDoubleClick = "Fill";
      # Window menu shortcuts on ctrl-alt (^~), where AeroSpace had them, so
      # they work from the Planck too (it has no Apple fn/globe key). Halves on
      # the arrows (one shortcut per menu item, so not also on h/i). Apps pick
      # these up when relaunched. Needs "Displays have separate Spaces" ON,
      # else the tiling items are greyed out.
      CustomUserPreferences.NSGlobalDomain.NSUserKeyEquivalents = let
        key = u: builtins.fromJSON ''"\u${u}"''; # NSUpArrowFunctionKey etc.
      in {
        "Fill" = "^~f";
        "Center" = "^~c";
        "Return to Previous Size" = "^~r";
        "Left" = "^~" + key "F702";
        "Right" = "^~" + key "F703";
        "Top" = "^~" + key "F700";
        "Bottom" = "^~" + key "F701";
        "Left & Right" = "^~s";
      };
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
   homebrew = {
     enable = true;
     casks = myCasks;
     brews = myBrews;
     taps = [ "nikitabobko/tap" ];
     # masApps = myMasApps;
   # onActivation.cleanup = "zap";
     onActivation.autoUpdate = true;
     # upgrades are manual on every Mac (LATB, 2026-09-26): run `brew upgrade`
     # yourself; a switch only installs what is missing
     onActivation.upgrade = false;
     # show what brew bundle installs (download/build/install lines), not
     # only the "Homebrew bundle..." header
     onActivation.extraFlags = [ "--verbose" ];
   };
#   system.activationScripts.postUserActivation.text = ''
#      # Following line should allow us to avoid a logout/login cycle
#      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
#  '';

  # system.activationScripts.applications.text = let
  #   env = pkgs.buildEnv {
  #     name = "system-applications";
  #     paths = config.environment.systemPackages;
  #     pathsToLink = "/Applications";
  #   };
  # in
  #   pkgs.lib.mkForce ''
  #   # Set up applications.
  #   echo "setting up /Applications..." >&2
  #   rm -rf /Applications/Nix\ Apps
  #   mkdir -p /Applications/Nix\ Apps
  #   find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  #   while read -r src; do
  #     app_name=$(basename "$src")
  #     echo "copying $src" >&2
  #     ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  #   done
  # '';

}

