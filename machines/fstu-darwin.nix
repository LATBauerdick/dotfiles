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
# Nix lives on its own APFS volume on this boot (fresh install, 2026-10-04),
# not on ZFS pool z: that pool's z/nix belonged to the macOS 27 boot (MHD).
#
# oMLX: the HEAD build with the custom kernel, from Jundot's tap, run as a brew
# service for bauerdic (a LaunchAgent, so it starts at bauerdic's login).
# Homebrew lives on the shared /opt volume, so the build that lstu's macOS 27
# boot made is already installed; brew bundle only (re)starts the service.
# Models and settings: /home/bauerdic/.omlx (moved from latb, 2026-10-04).
# Tailnet exposure is not nix's business; once, by hand:
#   /Applications/Tailscale.app/Contents/MacOS/Tailscale serve --bg 8000
# -> https://fstu.taild2340b.ts.net/ (tailnet only), as on lstu.

{ config, pkgs, lib, ... }:
{
  homebrew.taps = [ "jundot/omlx" ];
  homebrew.brews = [
    {
      name = "jundot/omlx/omlx";
      args = [ "HEAD" "with-custom-kernel" ];
      start_service = true;
    }
  ];

  # A server: never sleep, come back after a power cut (to the FileVault
  # prompt; see above). MDM energy settings, if any, win over these.
  power.sleep.computer = "never";
  power.restartAfterPowerFailure = true;
}
