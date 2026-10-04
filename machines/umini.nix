# umini — Mac mini Late 2012 (Macmini6,2, i7-3615QM, 16 GB), NixOS.
# The home ZFS/media server before umac (until ~2023); takes the role back from
# upro (decided 2026-10-03: upro and lstu are FNAL property, umini is private).
# Rebuilt 2026-10-04 from upro.nix's server half on umac.nix's x86 base.
#
# Migration notes (do these at cutover, not before). Runbook pattern:
# ~/Notes/Notes/Claude/2026-09-19-umac-to-upro-cutover-runbook.md
#  - zfsPools starts EMPTY; flip to the full list once the enclosures are
#    attached. Export every pool on upro first: a cleanly exported pool imports
#    here without -f. All hosts run OpenZFS 2.4.4 — do NOT `zpool upgrade`, so
#    the pools can still go back to upro or umac.
#  - delete the stub dirs under /data (left from 2025) BEFORE the pool mounts
#    over them; an empty deluge ssl/ stub is what crashed deluged on upro.
#  - plex/jellyfin data keep their -umac names (z0/d/plex-umac etc.).
#  - syncthing: copy upro's ~/.config/syncthing (identity OMJXHGY) over umini's
#    own (YNPSBSG, retired) with the service stopped on both.
#  - tailscale: routes + exit node move from upro at cutover
#    (tailscaleRoutingServer below, then approve in the admin console).
#  - samba users need `sudo smbpasswd -a latb` once on this machine.

{ config, pkgs, lib, ... }@args:
let
  hostname = "umini";
  hostId = "28c80f12"; # head -c 8 /etc/machine-id
  plexEnable = true;
  jellyfinEnable = true;
  delugeEnable = false; # runs on lmini since 2026-09-26
  krb5Enable = true;
  tailscaleEnable = true;
  tailscaleRoutingServer = true; # since the 2026-10-04 cutover; upro is off
  tailnetName = "taild2340b.ts.net";

  zfsPools = [ "z3" "z2" "z1" "z0" ]; # force-imported 2026-10-04 (upro could not export: z2 suspended)
  # plex, jellyfin and syncthing keep their state/folders on the pools; they
  # start only once pools are listed
  poolsAttached = zfsPools != [ ];

  # Role names announced over mDNS in addition to the hostname, so clients
  # (Infuse on the Apple TV, Finder, Arq) can use e.g. usrv.local and keep
  # working when the server role moves to another machine — move this list
  # with it (at cutover: [ "usrv" ], and remove it from upro.nix). Plain-DNS
  # `usrv` is a UniFi local DNS record on the gateway.
  mdnsAliases = [ "usrv" ];
  aliasUnits = lib.listToAttrs (map (alias: lib.nameValuePair "avahi-alias-${alias}" {
    description = "mDNS alias ${alias}.local for this host";
    after = [ "avahi-daemon.service" "network-online.target" ];
    requires = [ "avahi-daemon.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 10;
    };
    script = ''
      ip=$(${pkgs.iproute2}/bin/ip -4 -o route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{ for (i = 1; i <= NF; i++) if ($i == "src") print $(i+1) }')
      [ -n "$ip" ] || { echo "no default-route address yet"; exit 1; }
      exec ${pkgs.avahi}/bin/avahi-publish-address -R ${alias}.local "$ip"
    '';
  }) mdnsAliases);
in {
  imports =
    [ # hardware scan results imported via hardware/umini.nix in the flake
      ../pkgs/plex.nix
    ];

  system.stateVersion = "22.11"; # Did you read the comment?

  nix.settings.trusted-users = [ "root" "latb" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 268435456; # 256 MB; the 64 MB default warns on big closures

  # /boot is a 200 MB ESP; one kernel+initrd is ~45 MB
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # hardware/umini.nix loads Broadcom's wl driver for the built-in Wi-Fi
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-63-6.18.46"
    "broadcom-sta-6.30.223.271-59-6.18.31"
    "broadcom-sta-6.30.223.271-57-6.12.46"
    "broadcom-sta-6.30.223.271-57-6.12.48"
    "broadcom-sta-6.30.223.271-59-6.12.63"
  ];

# Thunderbolt support, see https://nixos.wiki/wiki/Thunderbolt
  services.hardware.bolt.enable = true;

  networking = {
    useDHCP = false;
    interfaces.enp1s0f0.useDHCP = true;

    hostName = hostname;
    hostId = hostId;
    nameservers = [ "1.1.1.1" ];
    search = [ tailnetName ];

    networkmanager.enable = true;
    # wired only: with Wi-Fi up, Plex advertised 10.23.1.128 (wlp2s0) as its
    # private address, so LAN clients could stream over Wi-Fi (2026-10-04)
    networkmanager.unmanaged = [ "wlp2s0" ];

    firewall.enable = true;
    firewall.allowPing = true;
# ports for services (samba, slimserver, roon ARC, plex, deluge web) — as umac
    firewall.allowedTCPPorts = [ 53 445 139 3389 9000 3483 32400 55000 55002 3000 ];
    firewall.allowedTCPPortRanges = [ { from = 9330; to = 9339; }
                                      { from = 30000; to = 30010; }
    ];
# open firewall ports for mosh
    firewall.allowedUDPPortRanges = [ { from = 60001; to = 61000; } ];
    firewall.allowedUDPPorts = [ 53 137 1383 3483 55000 9003 ];
  };

  services.tailscale.enable = tailscaleEnable;
  services.tailscale.useRoutingFeatures =
    if tailscaleRoutingServer then "server" else "client";
# prefs persist in tailscaled state; at cutover run once
#   tailscale up --ssh --accept-routes --advertise-exit-node --advertise-routes=10.23.1.0/24,10.23.30.0/24

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
# On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.enp1s0f0.accept_ra" = 2;
    "net.ipv6.conf.enp1s0f0.autoconf" = 1;
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches" = 204800; # default: 8192
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg

    ncurses
    krb5
    git
    gnumake
    gcc
    fzf
    psmisc # things like killall
    lshw
    lzop
    mbuffer
    sanoid
    pv
    usbutils
    thunderbolt
    ethtool
    lm_sensors
    vim
    neovim
    curl
  # To make SMB mounting easier on the command line
    cifs-utils
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

  # OpenSSH on the LAN only, for Arq's SFTP backups from lmini (2026-10-04,
  # LATB). Interactive access stays Tailscale SSH: tailscaled answers port 22
  # on the tailnet itself, and the firewall opens 22 on the Ethernet only.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
    openFirewall = false;
  };
  networking.firewall.interfaces.enp1s0f0.allowedTCPPorts = [ 22 ];
  # lmini's ArqAgent key (~/.ssh/arq_lstu, no passphrase): file transfer only
  users.users.latb.openssh.authorizedKeys.keys = [
    ''restrict,command="${config.services.openssh.package}/libexec/sftp-server" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOG3S5B68n6W6Y5Jrjh/2nsszLsuACNtfM4v3T7buB1U arq-lmini''
  ];

  programs.mosh.enable = true;

  users.users.root.initialPassword = "root";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOXZjedCEONef8tQoqk8iZYODg0VoONlyfIz5tFfWXz latb@lmini.local"
  ];

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  # off until cutover: umini's own 2023 identity (YNPSBSG) must not sync;
  # at cutover it is replaced by upro's (OMJXHGY), see notes up top
  services.syncthing = {
    enable = poolsAttached;
    dataDir = "/home/latb/";
    user = "latb";
  };

# zfs setup — pools stay on upro until cutover; see migration notes up top
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler
  boot.zfs.extraPools = zfsPools;
  boot.zfs.forceImportRoot = false; # root is ext4; never force-import (26.11 default)

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Console screen blanking: no X, no display manager, nothing else owns the
  # screen. setterm's --powersave/--powerdown is what DPMS-offs the panel.
  boot.kernelParams = [ "consoleblank=600" ];

  systemd.services = aliasUnits // {
   console-blank = {
    description = "Console blanking and DPMS powerdown on tty1";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty@tty1.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # StandardInput=tty would wait forever for agetty to release the tty
      # (seen on upro 2026-09-17); open it as a plain file instead.
      StandardInput = "file:/dev/tty1";
      StandardOutput = "file:/dev/tty1";
      ExecStart = "${pkgs.util-linux}/bin/setterm --blank 10 --powersave powerdown --powerdown 15 --term linux";
    };
   };
  };

  systemd.tmpfiles.rules = lib.optionals delugeEnable [
    # deluge's torrents are configured with /data/deluge/... paths
    "L+ /data/deluge - - - - deluge-umac"
  ] ++ lib.optionals (jellyfinEnable && poolsAttached) [
    # jellyfin's database stores library and metadata paths as
    # /var/lib/jellyfin/... (umac's hand-made symlink). dataDir points at the
    # pool directly; this keeps the stored paths valid.
    "L+ /var/lib/jellyfin - - - - /data/jellyfin-umac/jellyfin"
  ];

  services.pulseaudio.enable = false;

  nixpkgs.config.plex.plexname = "umac"; # plex data dataset is z0/d/plex-umac; rename both or neither
  services.plex.enable = plexEnable && poolsAttached;

  services.deluge = {
    enable = delugeEnable;
    dataDir = "/data/deluge-umac"; # dataset is z0/d/deluge-umac
    web.enable = delugeEnable;
    web.openFirewall = delugeEnable;
  };

  services.slimserver.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar"
  ];

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

  services.jellyfin = {
    enable = jellyfinEnable && poolsAttached;
    openFirewall = true;
    # Dataset z0/d/jellyfin-umac mounts at /data/jellyfin-umac
    dataDir = "/data/jellyfin-umac/jellyfin";
  };
  # The dataset is owned by umac's dynamic jellyfin ids 990/988, pinned on upro
  # too. Both free on umini (checked 2026-10-04), so no chown -R is needed.
  users.users.jellyfin = lib.mkIf (jellyfinEnable && poolsAttached) { uid = 990; };
  users.groups.jellyfin = lib.mkIf (jellyfinEnable && poolsAttached) { gid = 988; };

# SMB file sharing
  services.gvfs.enable = true;
  services.samba = { enable = true;
    openFirewall = true;
    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a latb
    settings = {
      global.security = "user";
      homes = {
        browseable = "no";  # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
      media = {
        path = "/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "latb";
        "force group" = "users";
      };
      sync = {
        path = "/sync";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "latb";
        "force group" = "users";
      };
      arq = {
        path = "/arq";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "latb";
        "force group" = "users";
      };
    };
  };

}
