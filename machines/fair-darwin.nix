# fair — MacBook Air 13" M5 (FNAL property 149207), Fermilab-managed macOS.
# OS hostname MAC-149207 is pinned by MDM (the Makefile maps it to this
# config); tailnet node mac-149207, ssh nickname fair. Account bauerdic, home
# /Users/bauerdic — the physical path, as on lmini and fstu: macOS sandbox
# profiles take NFSHomeDirectory literally, and the Claude app refuses to trust
# repos under /home. No /home link here at all.
#
# Set up from scratch 2026-11-24 after the espresso-spill repair, with
# workstation/macs/setup-fair.md. Until then fair ran the shared
# m1mac.bauerdic config (home /home/bauerdic), which ftop still uses.
#
# Managed by Fermilab, which this config does not fight: FileVault, macOS
# updates and the hostname are MDM's.
#
# Tailscale: the standalone GUI app, installed by hand before nix (so not a
# cask here: brew refuses an app that is already in /Applications). The app
# can use an exit node but cannot serve Tailscale SSH, so there is no inbound
# ssh; fair is maintained from a Claude session on fair itself.

{ config, pkgs, lib, ... }:
{
  # merged with darwin/darwinCasks.nix
  homebrew.casks = [ "claude-code" ];
}
