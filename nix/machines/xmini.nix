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
  boot.loader.efi.canTouchEfiVariables = true;

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

  system.stateVersion = "22.11"; # Did you read the comment?

  # let it never sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

#  boot.loader.grub.extraEntries = ''
#    menuentry "Ubuntu" {
#      search --set=ubuntu --fs-uuid a51a44ba-d008-4a1c-b590-43dafa7bf8d0
#      configfile "($ubuntu)/boot/grub/grub.cfg"
#    }
#  '';

  services.xrdp.enable = true;
  /* services.xrdp.defaultWindowManager = "awesome-x11"; */
  services.xrdp.defaultWindowManager = "startplasma-x11";

  services.xserver = {
    enable = false;
    dpi=130;
    # dpi=218;
    # dpi=329;
    displayManager = {
      sddm.enable = false;
      /* lightdm.enable = true; */
      /* startx.enable = true; */
      /* defaultSession = "none+awesome"; */
    };

    desktopManager.plasma5.enable = false;
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
    PLASMA_USE_QT_SCALING = "1";
    /* GDK_SCALE = "2"; */
    /* GDK_DPI_SCALE = "0.5"; */
    /* _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; */
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

  networking.hostName = "xmini"; # Define your hostname.
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
    nextdns
    silver-searcher  # ag
    git
    gnumake
#    killall
    psmisc # things like killall
    lshw
    lzop
    mbuffer
    sanoid
    pv
    usbutils
    thunderbolt

    networkmanagerapplet
    xorg.xbacklight
    lm_sensors
    acpi

    vim
    neovim
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
  services.openssh.settings.passwordAuthentication = false;
  services.openssh.settings.permitRootLogin = "yes";
  services.openssh.settings.X11Forwarding = true;
  users.users.root.initialPassword = "root";

  services.autossh.sessions = [
    { extraArguments = " -i ~/.ssh/id_auto -N -R 8388:127.0.0.1:22 116.203.126.183 sleep 99999999999";
      monitoringPort = 17008;
      name = "reverse";
      user = "root"; } # make sure tat id_auto key is in remote root's authorized_keys
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
  # and the needed ports in the firewall for NextDNS, `services.samba`, slimserver, roon ARC
  networking.firewall.allowedTCPPorts = [ 53 445 139 3389 9000 3483 55000 ];
  # open firewall ports for mosh, wireguard
  networking.firewall.allowedUDPPortRanges = [
    { from = 60001; to = 61000; }
  ];
  # the needed ports in the firewall for NextDNS, `services.samba`, slimserver, roon ARC
  networking.firewall.allowedUDPPorts = [ 53 137 1383 3483 55000 ];
# NextDNS config
  networking = {
    # firewall = {
    #   allowedTCPPorts = [ 53 ];
    #   allowedUDPPorts = [ 53 ];
    # };
    nameservers = [ "45.90.28.239" "45.90.30.239" ];
  };
  services.nextdns = {
    enable = true;
    arguments = [ "-config" "59b664" "-listen" "0.0.0.0:53" ];
  };




  programs.mosh.enable = true;

# zfs setup
  # usrv  networking.hostId = "41ca8470";
  networking.hostId = "ee3ccc06"; # head -c 8 /etc/machine-id
  boot.initrd.supportedFilesystems = [ "zfs" ]; # Not required if zfs is root-fs (extracted from filesystems) 
  boot.supportedFilesystems = [ "zfs" ]; # Not required if zfs is root-fs (extracted from filesystems)
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.

  /* fileSystems."/media" = */
  /*   { device = "h/m"; */
  /*     fsType = "zfs"; */
  /*     options = [ "zfsutil" ]; */
  /*   }; */
  boot.zfs.extraPools = [ ];

  fonts.fontDir.enable = true;
  fonts.enableDefaultFonts = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
#    (nerdfonts.override { fonts = [ "Iosevka" "Lekton" ]; })
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

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "plex";
    group = "plex";
    dataDir = "/data/plex-xmini";
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
