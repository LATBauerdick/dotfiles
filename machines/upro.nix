# upro — MacBook Pro 14" M1 Max running NixOS via Asahi (nixos-apple-silicon).
# Derived from umac.nix (2026-09-17); upro takes over umac's ZFS/media-server role.
#
# Migration notes (do these at cutover, not before):
#  - zfsPools below starts EMPTY; flip to the full list once the USB drives are
#    attached. First import on this machine needs `zpool import -f <pool>` (new
#    hostId), after exporting cleanly on umac.
#  - deluge/plex data dirs are named after umac (z0/d/deluge-umac etc.); either
#    `zfs rename` the datasets or keep the -umac paths — dataDir below keeps them.
#  - tailscale: upro joins as a NEW node; exit-node/route advertising stays on
#    umac until cutover (flag below), else both advertise the home routes.
#  - autossh reverse tunnel stays disabled while umac holds port 8387.
#  - samba users need `sudo smbpasswd -a latb` once on this machine.

{ config, pkgs, lib, ... }@args:
let
  hostname = "upro";
  hostId = "9e11c252"; # random; regenerate with head -c 8 /etc/machine-id if preferred
  plexEnable = false;
  jellyfinEnable = false;
  roonEnable = false;
  delugeEnable = false;
  krb5Enable = true;
  tailscaleEnable = true;
  tailscaleRoutingServer = false; # flip at cutover, when umac stops advertising
  tailnetName = "taild2340b.ts.net";

  zfsPools = [ ]; # at cutover: [ "z3" "z2" "z1" "z0" ]
in {
  imports =
    [ # hardware scan results imported via hardware/upro.nix in the flake
      ../pkgs/plex.nix
    ];

  system.stateVersion = "26.11"; # Did you read the comment?

# ---- Apple Silicon (Asahi) ----
  hardware.asahi.enable = true;
  # Apple Video Decoder firmware: needs pkgs.avd-fw, which entered nixpkgs
  # after this flake's current pin (2026-08-26). Flip to true (or drop the
  # line, the default is on) once a flake update brings it in.
  hardware.asahi.avd.enable = false;
  # Peripheral firmware (Wi-Fi etc.) is read from the ESP at /boot/vendorfw,
  # which pure flake eval cannot see — rebuild with --impure. Do NOT copy
  # firmware.cpio into this (public) repo; it is Apple's, non-redistributable.

  # Use the systemd-boot EFI boot loader; U-Boot cannot write EFI variables.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  # Asahi kernel+initrd are 60-100 MB per generation; unlimited generations is
  # what kept filling umac's 197 MB /boot. Install with a 2 GB ESP (see plan)
  # and cap the copies kept there regardless.
  boot.loader.systemd-boot.configurationLimit = 10;

  # US keyboard: fixes `/~ swapped with </> on Apple internal keyboards
  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';

  # Readable console on the 254-ppi internal panel (the installer's
  # `setfont ter-v32n` made permanent)
  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    earlySetup = true;
  };

# ---- server duty on a laptop ----
  # No hibernation on Asahi; this machine is an always-on server.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Console screen blanking (same recipe as umac/fmini). No X, no display
  # manager, so nothing else owns the screen. The kernel timer blanks the
  # framebuffer (and survives an agetty reset); setterm's --powersave /
  # --powerdown is what actually DPMS-offs the panel. Verified on upro
  # 2026-09-17: card1-eDP-1 dpms=Off and apple-panel-bl actual_brightness=0
  # once the blank timer expires.
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

  # 32 GB RAM runs this load on umac in 16 with no swap; zram is plenty.
  zramSwap.enable = true;

# ---- ad-hoc graphical terminal (decided 2026-09-18) ----
  # No desktop, no display manager, nothing running unless invoked. From a
  # login on the laptop's own console (a VT — not over ssh, which holds no
  # seat), run
  #     cage-ghostty
  # cage is a Wayland kiosk compositor: it takes the display, runs ghostty
  # fullscreen, and returns to the text VT when the shell exits. The wrapper
  # passes -s (keep Ctrl+Alt+Fn VT switching, off by default in a kiosk) and
  # GDK_SCALE=2 (cage has no output-scale setting; the panel is 254 ppi).
  # While cage holds the display nothing blanks the panel, lid closed or not
  # — exit when done. Swap for sway later if idle/lid handling is wanted.
  hardware.graphics.enable = true; # Asahi GPU is in mainline Mesa; the old
                                   # hardware.asahi.useExperimentalGPUDriver is gone
  fonts.packages = [
    # family name "Iosevka Term", as in users/user/ghostty/config (prebuilt, no compile)
    (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
  ];

  services.xserver = {
    enable = false;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire (Asahi speaker/codec setup rides on
  # hardware.asahi.enable).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  programs.firefox.enable = true;

  # use unstable nix so we can access flakes
  nix.settings.trusted-users = [ "root" "latb" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = hostname;
    hostId = hostId;
    nameservers = [ "1.1.1.1" ];
    search = [ tailnetName ];

    networkmanager.enable = true;
    # wpa_supplicant has no WPA3 on Broadcom; iwd is the Asahi recommendation
    networkmanager.wifi.backend = "iwd";

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
# at cutover, mirror umac's tailscale-autoconnect unit (exit node + routes);
# until then a plain `tailscale up --ssh` at the machine is enough

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    # Note that inotify watches consume 1kB on 64-bit machines.
    # needed for syncthing
    "fs.inotify.max_user_watches" = 204800; # default: 8192
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  environment.systemPackages = with pkgs; [

    cage
    ghostty
    (writeShellScriptBin "cage-ghostty" ''
      exec env GDK_SCALE=2 ${cage}/bin/cage -s -- ${ghostty}/bin/ghostty "$@"
    '')

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

    ethtool
    lm_sensors

    vim
    neovim
    curl
  # To make SMB mounting easier on the command line
    cifs-utils
  ];

  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;

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
    enable = ! tailscaleEnable; # Tailscale SSH is the only way in (decided 2026-09-17)
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "yes";
    openFirewall = true;
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

# zfs setup — pools stay on umac until cutover; see migration notes up top
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler
  boot.zfs.extraPools = zfsPools;

  nixpkgs.config.plex.plexname = "umac"; # plex data dataset is z0/d/plex-umac; rename both or neither
  services.plex.enable = plexEnable;

  services.deluge = {
    enable = delugeEnable;
    dataDir = "/data/deluge-umac"; # dataset is z0/d/deluge-umac; zfs rename to move to -upro
    web.enable = delugeEnable;
    web.openFirewall = delugeEnable;
  };

  services.roon-server = {
    enable = roonEnable;
    openFirewall = roonEnable;
  };

  services.slimserver.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "roon-bridge"
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
    enable = jellyfinEnable;
    openFirewall = true;
  };

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
        "force user" = "latb";
        "force group" = "users";
      };
    };
  };

}
