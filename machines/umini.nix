# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }@args:
let
  hostname = "umini";
  hostId = "28c80f12"; # head -c 8 /etc/machine-id
  plexEnable = true;
  roonEnable = true;
  roonBridgeEnable = false;
  delugeEnable = true;
  unifiEnable = false;
  nextdnsEnable = false;
  adguardEnable = true;
  krb5Enable = true;
  tailscaleEnable = true;
  tailnetName = "taild2340b.ts.net";

  zfsPools = [ "h2" "z2" "z1" "z0" ];
in {
  imports =
    [ # Include the results of tbe hardware scan.
# done elsewhere      ./hardware-configuration.nix
      ../pkgs/plex.nix
      ../pkgs/adguard.nix
    ];

  system.stateVersion = "22.11"; # Did you read the comment?
  # use unstable nix so we can access flakes
  nix.settings.trusted-users = [ "root" "latb" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    hostName = hostname;
    hostId = hostId;
    nameservers = [ "1.1.1.1" ];
    search = [ tailnetName ];

    networkmanager.enable = true;
    ### networkmanager.insertNameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];

    ### wireless.enable = true;

    firewall.enable = true;
    firewall.allowPing = true;
# ports for services.xrdp, NextDNS, samba, slimserver, roon ARC
    firewall.allowedTCPPorts = [ 53 445 139 3389 9000 3483 32400 55000 55002 3000 ];
# open firewall ports for mosh, wireguard
    firewall.allowedUDPPortRanges = [ { from = 60001; to = 61000; } ];
# ports for NextDNS, `services.samba`, slimserver, roon ARC
    firewall.allowedUDPPorts = [ 53 137 1383 3483 55000 ];
  };

  services.tailscale.enable = tailscaleEnable;
  services.tailscale.useRoutingFeatures = "server";
# make sure tailscale starts with exit-node enabled
  systemd.services.tailscale-autoconnect = {
    enable = tailscaleEnable;
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --advertise-exit-node --accept-routes --ssh

      # see https://tailscale.com/kb/1320/performance-best-practices#ethtool-configuration
      # set NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
      # /run/current-system/sw/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    /* # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52 */
    /* # By default, not automatically configure any IPv6 addresses. */
    /* "net.ipv6.conf.all.accept_ra" = 0; */
    /* "net.ipv6.conf.all.autoconf" = 0; */
    /* "net.ipv6.conf.all.use_tempaddr" = 0; */

# On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.eth0.accept_ra" = 2;
    "net.ipv6.conf.eth0.autoconf" = 1;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    krb5
    silver-searcher
    git
    gnumake
    gcc
    fzf
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
    ethtool
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

  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  # fonts.enableGhostscriptFonts = true;
  fonts.packages = with pkgs; [
#    (nerdfonts.override { fonts = [ "Iosevka" "Lekton" ]; })
#    corefonts
  ];

  programs.zsh.enable = true;

  security.sudo = {
    wheelNeedsPassword = false;
    extraRules = [
      { users = [ "latb" ];
        commands = [ { command = "ALL"; options = [ "NOPASSWD" "SETENV" ]; } ];
      }
    ];
  };

  security.krb5 = {
    package = pkgs.krb5;
    enable = krb5Enable;
    settings = {
      libdefaults.default_realm = "FNAL.GOV";
      realms."FNAL.GOV" = {
        kdc = [
                "krb-fnal-fcc3.fnal.gov:88"
                "krb-fnal-2.fnal.gov:88"
                "krb-fnal-3.fnal.gov:88"
                "krb-fnal-1.fnal.gov:88"
                "krb-fnal-4.fnal.gov:88"
                "krb-fnal-enstore.fnal.gov:88"
                "krb-fnal-fg2.fnal.gov:88"
                "krb-fnal-cms188.fnal.gov:88"
                "krb-fnal-cms204.fnal.gov:88"
                "krb-fnal-d0online.fnal.gov:88"
                "krb-fnal-nova-fd.fnal.gov:88"
        ];
        master_kdc = "elmo.fermi.win.fnal.gov:88";
        admin_server = "krb-fnal-admin.fnal.gov";
        default_domain = "fnal.gov";
      };
      realms."CERN.CH" = {
        kdc = "cerndc.cern.ch:88";
        default_domain = "cern.ch";
        kpasswd_server = "afskrb5m.cern.ch";
        admin_server = "afskrb5m.cern.ch";
      };
    };
  };

  services.openssh = {
    enable = ! tailscaleEnable;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "yes";
  # services.openssh.settings.X11Forwarding = true;
    openFirewall = ! tailscaleEnable; # if tailscale, no ssh on port 22
  };

  programs.mosh.enable = true;

  users.users.root.initialPassword = "root";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOXZjedCEONef8tQoqk8iZYODg0VoONlyfIz5tFfWXz latb@lmini.local"
  ];

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  services.syncthing = {
    enable = true;
    dataDir = "/home/latb/";
    user = "latb";
  };
  boot.kernel.sysctl = {
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches"   =  204800;   # default:  8192
  #  "fs.inotify.max_user_instances" =    1024;   # default:   128
  #  "fs.inotify.max_queued_events"  =   32768;   # default: 16384
  };


  services.autossh.sessions = [
    { extraArguments = " -i ~/.ssh/id_auto -N -R 8387:127.0.0.1:22 116.203.126.183 sleep 99999999999";
      monitoringPort = 17007;
      name = "reverse";
      user = "root"; } # make sure tat id_auto key is in remote root's authorized_keys
  ];

  # NextDNS config
  services.nextdns = { enable = nextdnsEnable;
    arguments = [ "-config" "59b664" "-listen" "0.0.0.0:53" ];
  };

  # Binary Cache for Haskell.nix
  # nix.settings.trusted-public-keys = [
  #   "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  # ];
  # nix.settings.substituters = [
  #   "https://cache.iog.io"
  # ];

# zfs setup
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
  boot.zfs.extraPools = zfsPools;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # hardware.pulseaudio.enable = true;
  services.pulseaudio.enable = true;

# Thunderbolt support, see https://nixos.wiki/wiki/Thunderbolt
# run `boltctl`, then for each device that is not authorized, execute 
# `boltctl enroll --chain UUID_FROM_YOUR_DEVICE`
  services.hardware.bolt.enable = true;

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  services.xrdp.enable = true;
  /* services.xrdp.defaultWindowManager = "awesome-x11"; */
  services.xrdp.defaultWindowManager = "startplasma-x11";

  services.displayManager.sddm.enable = false;
  services.xserver = { enable = false;
    dpi=130;
    # dpi=218;
    # dpi=329;
    displayManager = {
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

  nixpkgs.config.permittedInsecurePackages = [
                "electron-13.6.9"
  ];

  services.adguardhome.enable = adguardEnable;

  nixpkgs.config.plex.plexname = hostname;
  services.plex.enable = plexEnable;

  services.deluge.enable = delugeEnable;
  services.deluge = {
    dataDir = "/data/deluge-${hostname}";
    web.enable = true;
    web.openFirewall = true;
  };

  services.roon-server.enable = roonEnable;
  services.roon-server = {
    openFirewall = true;
  };


  services.unifi.enable = unifiEnable;
  services.unifi.unifiPackage = pkgs.unifi;
  services.unifi = {
    openFirewall = unifiEnable;
  };

  services.slimserver.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "roon-bridge"
      "unrar"
      "unifi"
  ];
  services.roon-bridge = {
      enable = roonBridgeEnable;
      openFirewall = roonBridgeEnable;
  };

  # mDNS, avahi
  services.avahi = { enable = true;
    nssmdns4 = true;
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

# SMB file sharing
  services.gvfs.enable = true;
  services.samba = { enable = true;
    openFirewall = true;
    # settings = ''
    #   workgroup = LATB
    #   server string = hostname
    #   netbios name = hostname
    #   hosts allow = 192.168.0  localhost
    #   hosts deny = 0.0.0.0/0
    #   guest account = nobody
    #   map to guest = bad user
    # '';

    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    settings = {
      global.security = "user";
      homes = {
        browseable = "no";  # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
      private = {
        path = "/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "latb"; # smbpasswd -a latb as root...
        "force group" = "users";
      };
      tm = { # configured for time machine backups
          path = "/tm";
          "valid users" = "latb";
          public = "no";
          writeable = "yes";
          "force user" = "latb";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
      };
      arq = {
        path = "/arq";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "latb"; # smbpasswd -a latb as root...
        "force group" = "users";
      };
    };
  };

}
