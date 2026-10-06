# fstu — the Mac Studio M2 Ultra (FNAL property 144343), booted from its
# Fermilab-managed macOS 26 volume "Macintosh HD". OS hostname mac-144343 is
# set by MDM; tailnet name fstu. Account bauerdic (uid 6170), home
# /home/bauerdic on the shared APFS "home" volume. Moves to the office as the
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
# Models and settings: /home/bauerdic/.omlx (moved from latb, 2026-10-04).
# Tailscale: the open-source tailscaled from Homebrew (not the GUI app), so
# that Tailscale SSH can serve ssh with Remote Login OFF — no sshd for
# Fermilab's scanners to find (2026-10-04, as on ftop; runbook
# ~/Notes/Notes/Claude/2026-09-18-tailscale-ssh-macos-runbook.md). tailscaled
# must run as root, which brew bundle's start_service cannot do; once, by hand:
#   sudo brew services start tailscale
#   sudo tailscale up --ssh --operator=bauerdic --hostname=fstu
#   tailscale serve --bg 8000      # -> https://fstu.taild2340b.ts.net/

{ config, pkgs, lib, ... }:
{
  homebrew.taps = [ "jundot/omlx" ];
  homebrew.brews = [
    "tailscale"   # tailscaled runs as a root service: see the note above
    {
      name = "jundot/omlx/omlx";
      args = [ "HEAD" "with-custom-kernel" ];
      start_service = true;
    }
  ];

  # Upgrading Homebrew here is different from the other Macs (2026-10-04):
  #  - formulae only: /opt/homebrew is the /opt volume shared with the Mac
  #    Studio's other boots, whose casks (Chrome, Slack, ...) a plain
  #    `brew upgrade` would install on this Fermilab boot;
  #  - python@3.11 stays pinned (`brew pin python@3.11`, stored on /opt): oMLX's
  #    HEAD build has its own venv on it and is never rebuilt by `brew upgrade`;
  #  - tailscaled is a root service and needs a restart to pick up the upgrade.
  # To move oMLX itself forward, deliberately: brew unpin python@3.11, then
  # brew reinstall --HEAD jundot/omlx/omlx --with-custom-kernel, then pin again.
  # a command, not an alias: nix-darwin's environment.shellAliases only reaches fish
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "brewup" ''
      set -e
      B=/opt/homebrew/bin/brew
      "$B" pin python@3.11
      "$B" upgrade --formula
      sudo "$B" services restart tailscale
    '')
  ];

  # /opt is its own APFS volume, mounted from fstab after launchd has already
  # tried homebrew.mxcl.tailscale at boot: tailscaled never ran and fstu
  # stayed off the tailnet until started by hand (2026-10-06, boot 13:02, first
  # start 13:18). Wait for the binary, then kick the brew-installed daemon.
  launchd.daemons.tailscale-kick = {
    script = ''
      /bin/wait4path /opt/homebrew/opt/tailscale/bin/tailscaled
      /bin/launchctl kickstart system/homebrew.mxcl.tailscale
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
}
