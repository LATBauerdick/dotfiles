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

  # keyd second-priority layers (space=raise, a=vi, right-shift number-row
  # quirk) — off until the core remap has proven itself; see the keyd block
  keydLayers = false;
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
  # --font-size=28: cage has no output-scale setting and GTK ignores GDK_SCALE
  # on Wayland (tried 2026-09-18, font came out tiny), so compensate for the
  # 254 ppi panel in ghostty itself.
  # While cage holds the display nothing blanks the panel, lid closed or not
  # — exit when done. Swap for sway later if idle/lid handling is wanted.
  hardware.graphics.enable = true; # Asahi GPU is in mainline Mesa; the old
                                   # hardware.asahi.useExperimentalGPUDriver is gone
  fonts.packages = [
    # family name "Iosevka Term", as in users/user/ghostty/config (prebuilt, no compile)
    (pkgs.iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
    # oh-my-posh theme uses Nerd Font glyphs (os icon, git branch); fontconfig
    # falls back to this for them, as macOS does with its Nerd Font casks
    pkgs.nerd-fonts.symbols-only
  ];

# ---- keyboard: Colemak-wide on the internal keyboard only (2026-09-18) ----
  # keyd remaps at the evdev layer, before console, cage or sway see the keys,
  # so one config covers all three. Requirements (LATB, 2026-09-18): the
  # alphanumeric remap and caps lock as control come first; the Karabiner
  # layers are second priority and sit behind `keydLayers` above.
  # Scope: ids = the Apple SPI Keyboard (05ac:0342) — USB keyboards such as the
  # Planck are not touched. The trackpad shares that id and keyd DID grab it on
  # the first switch ("appears to be a trackpad ... mouse movement is likely to
  # break"), and the k: prefix did not help because keyd classifies the trackpad
  # as a keyboard as well; the name hash in the id is what separates them.
  # Both sides of a binding are PHYSICAL evdev key names (apostrophe semicolon
  # dot slash leftbrace rightbrace minus equal). Translated from the Karabiner
  # rules active on lmini, where the macOS layout is plain "U.S." too.
  # A syntax error leaves the keyboard unmapped rather than failing the build:
  # check `journalctl -u keyd` after a switch; `systemctl stop keyd` = QWERTY.
  # Do NOT create users.groups.keyd: keyd then tries setgid, the hardened unit
  # denies it, and the service dies in a restart loop (seen 2026-09-18). The
  # "failed to set effective group" warning without the group is harmless.
  services.keyd = {
    enable = true;
    keyboards.internal = {
      # full id incl. the device-name hash (from the keyd log / `keyd monitor`):
      # matching is by prefix, and 05ac:0342 alone also grabs the trackpad
      ids = [ "05ac:0342:89b7fedc" ];
      settings = {
        main = {
          # Colemak Wide (ANSI): top row
          e = "f"; r = "p"; t = "g"; y = "apostrophe"; u = "j"; i = "l"; o = "u"; p = "y";
          # home row
          s = "r"; d = "s"; f = "t"; g = "d"; h = "semicolon"; j = "h"; k = "n"; l = "e";
          semicolon = "i"; apostrophe = "o";
          # bottom row
          n = "slash"; m = "k"; comma = "m"; dot = "comma"; slash = "dot";
          # caps lock is control; a lone tap gives esc, as on the Mac.
          # Plain control instead: capslock = "leftcontrol";
          capslock = "overload(control, esc)";
        } // lib.optionalAttrs keydLayers {
          rightshift = "layer(rshift)";
          space = "overloadt2(raise, space, 200)";             # hold 200 ms, or tap a key while held
          a = "overloadi(a, overloadt2(vi, a, 200), 150)";     # plain a when typing flows (<150 ms)
          "equal+backspace" = "delete";                        # Karabiner: = and backspace together
        };
      } // lib.optionalAttrs keydLayers {
        # right shift is plain shift, except the right hand's number row and
        # physical h, which Karabiner shifts one column (the "wide" quirk)
        "rshift:S" = {
          "7" = "S-equal"; "8" = "S-7"; "9" = "S-8"; "0" = "S-9";
          minus = "S-0"; equal = "S-minus"; h = "S-rightbrace";
        };
        # space held: numbers on the home row, symbols above and below
        raise = {
          a = "1"; s = "2"; d = "3"; f = "4"; g = "5";
          j = "6"; k = "7"; l = "8"; semicolon = "9"; apostrophe = "0";
          q = "S-1"; w = "S-2"; e = "S-3"; r = "S-4"; t = "S-5";
          u = "S-6"; i = "S-7"; o = "S-8"; p = "S-9"; leftbrace = "S-0";
          rightbrace = "minus"; backslash = "S-equal";
          z = "leftbrace"; x = "rightbrace"; c = "minus"; v = "equal";
          b = "S-9"; m = "S-0"; comma = "apostrophe";
        };
        # a held: arrows on the right home row (physical j k l ; '), m = backspace
        vi = {
          j = "left"; k = "down"; l = "up"; semicolon = "right";
          apostrophe = "enter"; m = "backspace";
        };
      };
    };
  };

# ---- sway: same "one fullscreen terminal" idea, with input tuning (2026-09-18) ----
  # cage has no configuration at all, so trackpad speed and scaling cannot be
  # set there (accepted for cage — cage-ghostty stays as the simple option).
  # sway can, and starts ghostty fullscreen so it looks the same.
  # From a console login: `sway`. Mod4 is the command key. Mod4+Return opens
  # another terminal, Mod4+Shift+BackSpace exits back to the VT (chosen to be
  # layout-independent). /etc/sway/config is what NixOS's sway reads when the
  # user has no ~/.config/sway/config; home-manager is untouched.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = [ pkgs.swayidle pkgs.wl-clipboard ];
  };
  environment.etc."sway/config".text = ''
    set $mod Mod4

    # 254 ppi panel: integer 2x, so ghostty's 14 pt config is right as is
    output eDP-1 scale 2

    # Trackpad. pointer_accel runs -1..1; 0 is libinput's default, which felt
    # far too slow on the Apple trackpad. Adjust and `swaymsg reload`.
    input type:touchpad {
        accel_profile adaptive
        pointer_accel 0.8
        natural_scroll enabled
        tap enabled
        click_method clickfinger
        dwt enabled
    }
    # layout is plain us: keyd already produced Colemak-wide before sway sees it
    input type:keyboard xkb_layout us

    default_border none
    focus_follows_mouse no
    exec ghostty
    for_window [app_id="com.mitchellh.ghostty"] fullscreen enable

    bindsym $mod+Return exec ghostty
    bindsym $mod+Shift+q kill
    bindsym $mod+f fullscreen toggle
    bindsym $mod+Left focus left
    bindsym $mod+Right focus right
    bindsym $mod+Up focus up
    bindsym $mod+Down focus down
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Right move right
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+BackSpace exit

    # what cage could not do: panel off on lid close and after 10 min idle
    bindswitch --reload --locked lid:on output eDP-1 power off
    bindswitch --reload --locked lid:off output eDP-1 power on
    exec swayidle -w timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"'
  '';

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
      # 14 pt at the Mac's 2x scale == 28 pt at cage's 1x; later args override
      exec ${cage}/bin/cage -s -- ${ghostty}/bin/ghostty --font-size=28 "$@"
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
