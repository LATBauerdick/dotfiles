# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }@args:
let
  hostname = "fmini";
  hostId = "19889f4c"; # head -c 8 /etc/machine-id
  plexEnable = false;
  roonEnable = false;
  roonBridgeEnable = false;
  delugeEnable = false;
  unifiEnable = false;
  nextdnsEnable = false;
  adguardEnable = false;
  krb5Enable = true;
  tailscaleEnable = true;
  tailnetName = "taild2340b.ts.net";

  zfsPools = [ "z3" ];
in {
  imports =
    [ # Include the results of the hardware scan.
# done elsewhere      ./hardware-configuration.nix
      ../pkgs/plex.nix
      ../pkgs/adguard.nix
    ];

  system.stateVersion = "24.11"; # Did you read the comment?
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver = {
    enable = false;
    windowManager.qtile.enable = true;
    dpi=130;
    # dpi=218;
    # dpi=329;
  # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
    displayManager = {
      /* lightdm.enable = true; */
      /* startx.enable = true; */
      /* defaultSession = "none+awesome"; */
    };
    # desktopManager.plasma5.enable = false;
    /* windowManager.awesome = { */
    /*   enable = true; */
    /*   luaModules = with pkgs.luaPackages; [ */
    /*     luarocks     # is the package manager for Lua modules */
    /*     luadbi-mysql # Database abstraction layer */
    /*   ]; */
    /* }; */
  # Enable touchpad support (enabled default in most desktopManager).
  # libinput.enable = true;
  };
  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = false;
  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "awesome-x11"; */
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  # services.desktopManager.plasma6.enable = true;
  environment.variables = {
    PLASMA_USE_QT_SCALING = "1";
    /* GDK_SCALE = "2"; */
    /* GDK_DPI_SCALE = "0.5"; */
    /* _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"; */
  };

# Thunderbolt support, see https://nixos.wiki/wiki/Thunderbolt
# run `boltctl`, then for each device that is not authorized, execute 
# `boltctl enroll --chain UUID_FROM_YOUR_DEVICE`
  services.hardware.bolt.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "latb";

  # Install firefox.
  programs.firefox.enable = true;

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
    nameservers = [ ];
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
    "net.ipv6.conf.enp4s0.accept_ra" = 2;
    "net.ipv6.conf.enp4s0.autoconf" = 1;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    krb5
    # silver-searcher  # removed from nixpkgs (2026); rg replaces it
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
  # xorg.xbacklight
    lm_sensors
    acpi

    vim
    neovim
    curl
    # gui apps
    firefox
    # window manager stuff
    xmobar
  # nitrogen
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

  security = {
    sudo.wheelNeedsPassword = false;
    sudo.extraRules = [
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

  services.openssh.enable = false; #####################!!!!! true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";
  # services.openssh.settings.X11Forwarding = true;
  services.openssh.openFirewall = ! tailscaleEnable; # if tailscale, no ssh on port 22

  # Hardened 2026-04-22 (was only in fmini's working tree until 2026-10-07):
  # no root login, no mosh, no root ssh key.
  programs.mosh.enable = false;

  users.users.root.initialPassword = "root";

  time.timeZone = "America/Chicago";
  # The lab network blocks the public NTP pool: fmini drifted 34 min unsynced
  # (2026-10-07), which breaks Kerberos and skews snapshot times.
  networking.timeServers = [ "ntp.fnal.gov" ];

  i18n.defaultLocale = "en_US.UTF-8";

  # Off the syncthing network since 2026-10: the z3/s copies now come from
  # umini by syncoid (see the zfs section). ~/Notes and ~/Sync become
  # symlinks into the read-only replica /sync/syncthing/{Notes,Sync}.
  services.syncthing = {
    enable = false;
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
  # The z3 disks sit in an OWC ThunderBay 4 on Thunderbolt, and the domain's
  # security level is "user": the box must be authorized before its disks
  # appear. Nothing did that at boot (not enrolled in bolt), so
  # zfs-import-z3's 60 s wait ran out and the pool, and everything on it, had
  # to be imported by hand. Authorize this one enclosure, by unique_id, as
  # soon as udev sees it.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="d6010000-0080-7d08-a375-e80984941820", ATTR{authorized}=="0", ATTR{authorized}="1"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.

  /* fileSystems."/media" = */
  /*   { device = "h/m"; */
  /*     fsType = "zfs"; */
  /*     options = [ "zfsutil" ]; */
  /*   }; */
  boot.zfs.extraPools = zfsPools;
  boot.zfs.forceImportRoot = false; # root is ext4; never force-import (26.11 default)

  # Off-site copy of umini's syncthing datasets: fmini PULLS umini's sanoid
  # snapshots (z0/s/* -> z3/s/*) every hour, so umini cannot touch these
  # backups and fmini is no longer a syncthing device. The z3/s datasets were
  # seeded by syncoid from umini in 2025-01 and still share that snapshot, so
  # the first run is incremental.
  # Only the datasets with that common snapshot for now; p2021, p2025, p2026,
  # c1-p2024, c1-p2025 need a full send (step 2). The DEVONthink sync stores
  # (dtsync, dtpsync, dtasync) are not copied: ephemeral transport — the
  # databases reach fmini through Arq.
  # umini side, once (persists in the pool):
  #   zfs allow -u latb bookmark,hold,send,snapshot,destroy,mount z0/s
  # Plan: ~/Notes/Notes/Claude/2026-10-06-backup-structure-plan.md
  services.syncoid = {
    enable = true;
    interval = "*:15"; # after umini's sanoid run on the hour
    commonArgs = [ "--sshoption=StrictHostKeyChecking=accept-new" ];
    # module default plus destroy, so syncoid can prune its own old
    # syncoid_fmini_* marker snapshots on the target
    localTargetAllow = [ "change-key" "compression" "create" "mount" "mountpoint" "receive" "rollback" "destroy" ];
    commands = lib.genAttrs [
      "books" "c1" "c1-p2021" "c1-p2022" "c1-p2023" "docs" "docsarchive"
      "incoming" "jpegs" "lr" "mybooks" "p2022" "p2023" "p2024"
      "screensaver" "sjpegs" "syncthing"
    ] (d: { source = "latb@umini:z0/s/${d}"; target = "z3/s/${d}"; });
  };

  # Long retention for what syncoid brings in. fmini takes no snapshots of its
  # own (autosnap off) — it only prunes. umini makes no yearlies (they would pin
  # a year of deletions on its ~94 %-full z0), so history is 36 monthlies.
  services.sanoid = {
    enable = true;
    templates = {
      history = { hourly = 24; daily = 30; monthly = 36; yearly = 0; autosnap = false; autoprune = true; };
      photos  = { hourly = 0;  daily = 14; monthly = 36; yearly = 0; autosnap = false; autoprune = true; };
    };
    datasets = {
      "z3/s" = { useTemplate = [ "photos" ]; recursive = true; processChildrenOnly = true; };
    } // lib.genAttrs
      (map (d: "z3/s/${d}") [ "syncthing" "docs" "docsarchive" "mybooks" "lr" "incoming" ])
      (_: { useTemplate = [ "history" ]; });
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Console screen blanking. This machine runs with no X and no display
  # manager, so nothing else owns the screen. The kernel timer blanks the
  # framebuffer (and survives an agetty reset); setterm's --powersave /
  # --powerdown is what actually DPMS-offs the panel. Verified on umac:
  # dpms=Off, /sys/class/graphics/fb0/blank=4 once the timer expires.
  boot.kernelParams = [ "consoleblank=600" ];

  systemd.services.console-blank = {
    description = "Console blanking and DPMS powerdown on tty1";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty@tty1.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # setterm issues its ioctls on stdin and writes escapes to stdout, so
      # both must be the console. Open it as a plain file: StandardInput=tty
      # waits for the tty's controlling process (agetty) to release it, which
      # never happens, and the oneshot then hangs in "activating" forever
      # (seen on upro 2026-09-17; umac only ever won the race at boot).
      StandardInput = "file:/dev/tty1";
      StandardOutput = "file:/dev/tty1";
      ExecStart = "${pkgs.util-linux}/bin/setterm --blank 10 --powersave powerdown --powerdown 15 --term linux";
    };
  };

  services.pulseaudio.enable = false;

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
      arq = {
        path = "/arqf";
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
