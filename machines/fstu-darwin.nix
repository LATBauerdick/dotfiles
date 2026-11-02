# fstu — the Mac Studio M2 Ultra (FNAL property 144343), booted from its
# Fermilab-managed macOS 26 volume "Macintosh HD". OS hostname mac-144343 is
# set by MDM; tailnet name fstu. Account bauerdic (uid 6170), home
# /Users/bauerdic (moved off the separate "home" volume 2026-11-02; /home/bauerdic
# is a compat symlink until the old copy is removed). Moves to the office as the
# local-model server; nothing personal runs here (decided 2026-10-03/04).
#
# Managed by Fermilab, which this config does not fight: FileVault is enforced
# and automatic login disabled, so after every reboot nothing runs until
# bauerdic logs in at the console; macOS updates are installed on Fermilab's
# schedule (the shared SoftwareUpdate user prefs in darwin.nix are moot here).
#
# Nix: for now /nix is ZFS pool z's z/nix, shared with the macOS 27 boot (MHD),
# so it needs OpenZFS loaded (2.4.1p1 since 2026-10-04). No nix-collect-garbage
# on MHD: it deleted this boot's system once. A fresh APFS /nix comes with the
# pool-z clean-out. If /run/current-system is ever missing:
#   nix build .#darwinConfigurations.fstu.system
#   sudo ./result/sw/bin/darwin-rebuild switch --flake .#fstu
#
# oMLX: the HEAD build with the custom kernel, from Jundot's tap, run as a brew
# service for bauerdic (a LaunchAgent, so it starts at bauerdic's login).
# Homebrew lives on the shared /opt volume, so the build that lstu's macOS 27
# boot made is already installed; brew bundle only (re)starts the service.
# Models and settings: ~/.omlx (moved from latb 2026-10-04, to /Users 2026-11-02).
# Tailscale: the open-source tailscaled from Homebrew (not the GUI app), so
# that Tailscale SSH can serve ssh with Remote Login OFF — no sshd for
# Fermilab's scanners to find (2026-10-04, as on ftop; runbook
# ~/Notes/Claude/2026-09-18-tailscale-ssh-macos-runbook.md). tailscaled
# must run as root, which brew bundle's start_service cannot do; once, by hand:
#   sudo brew services start tailscale
#   sudo tailscale up --ssh --operator=bauerdic --hostname=fstu
#   tailscale serve --bg 8000      # -> https://fstu.taild2340b.ts.net/

{ config, pkgs, lib, ... }:
{
  # Since 2026-10-13 /opt is this boot's own (on the Data volume; the shared /opt
  # volume is gone) and Homebrew was reinstalled fresh. fstu gets the common
  # casks/brews of darwin/darwin.nix (LATB) plus these, merged:
  # the separate jundot/homebrew-omlx tap repo is gone (2026-10-13); the formula
  # now lives in the main repo, so the tap needs its URL
  homebrew.taps = [
    { name = "jundot/omlx"; clone_target = "https://github.com/jundot/omlx"; }
  ];
  homebrew.brews = [
    "tailscale"   # tailscaled runs as a root service: see the note above
    {
      name = "jundot/omlx/omlx";
      args = [ "HEAD" "with-custom-kernel" ];
      start_service = true;
    }
  ];

  # Upgrading Homebrew here is different from the other Macs (2026-10-04):
  #  - python@3.11 stays pinned (`brew pin python@3.11`, stored on /opt): oMLX's
  #    HEAD build has its own venv on it and is never rebuilt by `brew upgrade`;
  #  - tailscaled is a root service and needs a restart to pick up the upgrade.
  # To move oMLX itself forward, deliberately: brew unpin python@3.11, then
  # brew reinstall --HEAD jundot/omlx/omlx --with-custom-kernel, then pin again.
  # Needs full Xcode (+ Metal toolchain). Its post_install SIGKILLs on a stale
  # cached signature of libmlx (rewritten in place); recipe in the 2026-10-13
  # workspace log: re-copy the mlx binaries, add the mlx rpath to the kernels.
  # a command, not an alias: nix-darwin's environment.shellAliases only reaches fish
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "brewup" ''
      set -e
      B=/opt/homebrew/bin/brew
      "$B" pin python@3.11
      "$B" upgrade
      sudo "$B" services restart tailscale
    '')
  ];

  # /opt is its own APFS volume, mounted from fstab after launchd has already
  # tried sh.brew.tailscale at boot: tailscaled never ran and fstu
  # stayed off the tailnet until started by hand (2026-10-06, boot 13:02, first
  # start 13:18). Wait for the binary, then kick the brew-installed daemon.
  # A kickstart is not enough: when the executable is missing at boot launchd
  # logs "Missing executable detected" and drops the job, so kickstart answered
  # "Could not find service" (2026-10-07, boot 16:43). Load it again instead.
  launchd.daemons.tailscale-kick = {
    script = ''
      /bin/wait4path /opt/homebrew/opt/tailscale/bin/tailscaled
      echo "$(/bin/date) /opt ready"
      if /bin/launchctl print system/sh.brew.tailscale >/dev/null 2>&1; then
        /bin/launchctl kickstart system/sh.brew.tailscale
      else
        /bin/launchctl bootstrap system /Library/LaunchDaemons/sh.brew.tailscale.plist
      fi
      echo "$(/bin/date) done ($?)"
    '';
    serviceConfig = {
      RunAtLoad = true;
      StandardOutPath = "/var/log/tailscale-kick.log";
      StandardErrorPath = "/var/log/tailscale-kick.log";
    };
  };

  # A server: never sleep, come back after a power cut (to the FileVault
  # prompt; see above). MDM energy settings, if any, win over these.
  power.sleep.computer = "never";
  power.restartAfterPowerFailure = true;

  # They do win: MDM's EnergySaver profile sets System Sleep Timer 30, and pmset
  # showed sleep 30 despite the line above. Amphetamine only holds sleep off
  # while bauerdic is logged in, so fstu slept logged out at the console
  # (2026-11-02, 11:48, during the home move) and OpenZFS 2.4.1 panicked on
  # wake (new_vnode: free vnode still referenced), zeroing 19 nix store paths.
  # An assertion from boot needs no login, and the profile only sets the timer.
  # -s holds only on AC power, which is all a Mac Studio has.
  launchd.daemons.caffeinate = {
    serviceConfig = {
      ProgramArguments = [ "/usr/bin/caffeinate" "-s" ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  # Screen Sharing for the tailnet only: the built-in service, told to accept
  # local connections alone, reached through Tailscale SSH (`vnc-ssh fstu`,
  # users/user/home.nix). Port 5900 may still show as listening on the LAN, but
  # nothing off the machine gets a session (2026-11-02). The "no Screen Sharing
  # on FNAL Macs" rule in the Tailscale SSH runbook was a recollection, not a
  # known policy. Only the flag lives here; the service itself is switched on in
  # System Settings › General › Sharing (access: bauerdic only). Enabling it with
  # launchctl starts screensharingd but leaves com.apple.access_screensharing
  # empty, and every client gets "Screen Sharing is not permitted" (2026-11-02).
  system.activationScripts.postActivation.text = ''
    /usr/bin/defaults write /Library/Preferences/com.apple.RemoteManagement VNCOnlyLocalConnections -bool true
  '';
}
