# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
# done elsewhere      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "21.11"; # Did you read the comment?

  boot.loader.efi.canTouchEfiVariables = false;

# kernel patch for macbook pro 2015
  boot.kernelPatches = [
    { name = "poweroff-fix"; patch = ./patches/kernel/poweroff-fix.patch; }
    # { name = "hid-apple-keyboard"; patch = ./patches/kernel/hid-apple-keyboard.patch; }
  ];

  # let it never sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # hardware.bluetooth.enable = false;
  services.blueman.enable = true;

  hardware.facetimehd.enable = true;

  # hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  powerManagement.enable = true;

  programs.light.enable = true;

  services.mbpfan.settings.general = {
    enable = true;
    lowTemp = 61;
    highTemp = 64;
    maxTemp = 84;
  };


#  boot.loader.grub.extraEntries = ''
#    menuentry "Ubuntu" {
#      search --set=ubuntu --fs-uuid a51a44ba-d008-4a1c-b590-43dafa7bf8d0
#      configfile "($ubuntu)/boot/grub/grub.cfg"
#    }
#  '';

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "awesome-x11";
#  services.xrdp.defaultWindowManager = "startplasma-x11";

  services.xserver = {
    enable = true;
    dpi=130;
    # dpi=219;
    # dpi=329;
    displayManager = {
      sddm.enable = true;
      /* lightdm.enable = true; */
      /* startx.enable = true; */
      /* defaultSession = "none+awesome"; */
    };

    desktopManager.plasma5.enable = true;
    /* windowManager.awesome = { */
    /*   enable = true; */
    /*   luaModules = with pkgs.luaPackages; [ */
    /*     luarocks     # is the package manager for Lua modules */
    /*     luadbi-mysql # Database abstraction layer */
    /*   ]; */
    /* }; */
    # libinput.enable = true;
  };
  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

  # setup i3 windowing environment
  /* services.xserver = { */
  /*   desktopManager = { */
  /*     xterm.enable = false; */
  /*     wallpaper.mode = "scale"; */
  /*   }; */
  /*   displayManager = { */
  /*     defaultSession = "none+i3"; */
  /*     lightdm.enable = true; */
  /*   }; */
  /*   windowManager = { */
  /*     i3.enable = true; */
  /*   }; */
  /* }; */

  # use unstable nix so we can access flakes
  nix = {
      package = pkgs.nixUnstable;
      /* package = pkgs.nixFlakes; */
      extraOptions = "experimental-features = nix-command flakes";
  };

  networking.hostName = "usrv"; # Define your hostname.
  time.timeZone = "America/Chicago"; # Set your time zone.

 # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
#  virtualisation.docker.enable = true;


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    silver-searcher  # ag
    git
    gnumake
#    killall
    psmisc # things like killall
    lshw
    usbutils
    thunderbolt

    networkmanagerapplet
    xorg.xbacklight
    lm_sensors
    acpi

    vim
    curl
    # gui apps
    firefox
    # window manager stuff
    xmobar
    nitrogen
    picom
    dmenu
  # To make SMB mounting easier on the command line
    cifs-utils
  ];

 # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.forwardX11 = true;
  users.users.root.initialPassword = "root";

  services.autossh.sessions = [
    { extraArguments = " -N -R 8388:127.0.0.1:22 116.203.126.183 sleep 99999999999";
      monitoringPort = 17008;
      name = "reverse";
      user = "root"; }
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # nix.settings.trusted-users = [ "root" "btal" "bauerdic" ];

  boot.kernel.sysctl = {
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches"   =  204800;   # default:  8192
  #  "fs.inotify.max_user_instances" =    1024;   # default:   128
  #  "fs.inotify.max_queued_events"  =   32768;   # default: 16384
  };
  services.syncthing = {
    enable = true;
    dataDir = "/home/bauerdic/";
    user = "bauerdic";
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  # open firewall ports for services.xrdp
  # and the needed ports in the firewall for `services.samba`
  networking.firewall.allowedTCPPorts = [ 445 139 3389 ];
  # open firewall ports for mosh, wireguard
  networking.firewall.allowedUDPPortRanges = [
    { from = 60001; to = 61000; }
  ];
  # the needed ports in the firewall for `services.samba`
  networking.firewall.allowedUDPPorts = [ 137 1383 ];


  programs.mosh.enable = true;

# zfs setup
  networking.hostId = "41ca8470";
  # umini networking.hostId = "af58841e"; # head -c 8 /etc/machine-id
  boot.supportedFilesystems = [ "zfs" ];

  fileSystems."/mnt" =
    { device = "z/d";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/mnt/dev" =
    { device = "z/d/dev";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/mnt/zk" =
    { device = "z/d/zk";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/mnt/data" =
    { device = "z/d/data";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  fileSystems."/mnt/p2022" =
    { device = "z/d/p2022";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fonts.fontDir.enable = true;
  fonts.enableDefaultFonts = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Iosevka" "Lekton" ]; })
#    corefonts
#    dejavu_fonts
#    font-awesome-ttf
#    inconsolata
#    liberation_ttf
#    terminus_font
#    ubuntu_font_family
#    unifont
  ];

  nixpkgs.config.permittedInsecurePackages = [
                "electron-13.6.9"
  ];

  # appstream.enable = true;

  /* services.plex = { */
  /*   enable = true; */
  /*   openFirewall = true; */
  /* }; */

# SMB file sharing
  services.gvfs.enable = true;
  services.samba.openFirewall = true;
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = LATB
      server string = ursv
      netbios name = usrv
      security = user
      #use sendfile = yes
      #max protocol = smb2
      hosts allow = 192.168.0  localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      #browseable = yes
      #smb encrypt = required
    '';

    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    shares = {
      public = {
        path = "/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "bauerdic";
        "force group" = "users";
      };
      private = {
        path = "/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "bauerdic";
        "force group" = "users";
      };
      homes = {
        browseable = "no";  # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  # mDNS, avahi
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

}

