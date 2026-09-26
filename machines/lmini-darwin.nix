# lmini — Mac mini M4 (Mac16,10), 16 GB, macOS. Always-on home Mac: runs the
# Claude Code workspace, and is to take over Deluge from upro (upro is FNAL
# property; decided 2026-09-26).
#
# Per-host split, 2026-09-26: this module started EMPTY, so the first switch to
# darwinConfigurations.lmini activated exactly what m1mac.latb did (checked by
# comparing the two system outPaths). lmini-only settings land here, not in
# darwin/darwin.nix, which the laptops share.
#
# Planned (not yet written), see ~/Notes/Notes/Claude/2026-09-26-upro-services-on-lstu-proposal.md
# and memory/2026-09-26.md:
#  - Deluge as a dedicated `deluge` macOS user (lmini holds secrets.env, the
#    Keychain session and the fleet ssh agent), launchd daemons for deluged +
#    deluge-web, data on the APFS volume `sx5` (Samsung X5, 1 TB, volume UUID
#    CAF555F7-A327-4348-A3AA-08F44482F18A): ownership enabled, mounted at boot
#    via /etc/fstab, Spotlight off
#  - a TCC probe from a launchd job on sx5 before any of it goes live

{ config, pkgs, lib, ... }:
{
  # (homebrew.onActivation.upgrade = false lived here briefly; since
  # 2026-09-26 it is the shared default in darwin/darwin.nix for every Mac)
}
