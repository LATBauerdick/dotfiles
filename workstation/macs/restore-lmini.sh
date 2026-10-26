#!/bin/bash
# restore-lmini.sh — bring a freshly installed macOS (Apple Silicon) back to what
# lmini has: user latb, nix-darwin + home-manager (darwinConfigurations.lmini),
# Homebrew casks/brews, App Store apps, Tailscale, Syncthing, and the scheduled
# Claude jobs. Written 2026-10-26 from a survey of lmini.
#
# Before running:
#   - Setup Assistant: admin account with account name  latb  (home /Users/latb),
#     signed in to the Apple ID (the App Store step needs it)
#   - fetch this script (the repo is public; needs a push of this file first):
#       curl -fsSLO https://raw.githubusercontent.com/LATBauerdick/dotfiles/master/workstation/macs/restore-lmini.sh
#
# Usage:
#   bash restore-lmini.sh [base] [hostname]   system, nix, apps   (default: base lmini)
#   bash restore-lmini.sh post-sync           once Syncthing has delivered ~/Sync
#
# Re-runnable: every step skips what is already in place. The first run stops
# once for the Xcode Command Line Tools; run it again when they are installed.
set -euo pipefail

STEP="${1:-base}"
HOST="${2:-lmini}"
DOTFILES="$HOME/dotfiles"
REPO_HTTPS="https://github.com/LATBauerdick/dotfiles.git"
REPO_SSH="git@github.com:LATBauerdick/dotfiles.git"
NIX=/nix/var/nix/profiles/default/bin/nix
BREW=/opt/homebrew/bin/brew

# App Store apps as installed on lmini 2026-10-26 (`mas list`). darwin.nix keeps
# homebrew.masApps off, so these are not declarative.
MAS_APPS=(
    937984704   # Amphetamine
    1055511498  # Day One
    775737590   # iA Writer
    1136220934  # Infuse
    1464122853  # NextDNS
    361304891   # Numbers
    6720708363  # Obsidian Web Clipper
    6746662575  # Pixelmator Pro
    1529448980  # Reeder
    1491071483  # Tot
)

say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
die() { echo "error: $*" >&2; exit 1; }

preflight() {
    [ "$(uname -s)" = Darwin ] || die "macOS only"
    [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = 1 ] || die "Apple Silicon only (nixpkgs dropped x86_64-darwin; use make lite)"
    [ "$(id -u)" -ne 0 ] || die "run as latb, not root (it asks for sudo itself)"
    [ "$(id -un)" = latb ] || die "run as latb (the lmini config is for that user)"
    [ "$HOME" = /Users/latb ] || die "home must be /Users/latb, is $HOME"
    sudo -v
    # keep the sudo timestamp fresh for the long steps
    while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
}

base() {
    preflight

    say "1/11 hostname $HOST"
    if [ "$(scutil --get LocalHostName 2>/dev/null)" != "$HOST" ]; then
        sudo scutil --set ComputerName "$HOST"
        sudo scutil --set LocalHostName "$HOST"
        sudo scutil --set HostName "$HOST"
    fi

    say "2/11 Xcode Command Line Tools"
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install || true
        echo "Finish the Command Line Tools dialog, then run this script again."
        exit 0
    fi

    say "3/11 Rosetta"
    if [ ! -e /Library/Apple/usr/share/rosetta/rosetta ]; then
        sudo softwareupdate --install-rosetta --agree-to-license
    fi

    # /home -> /Users and the root mount points lmini has (see
    # ~/Sync/_configs/config/lmini/README.md). The Lix installer adds its own
    # "nix" line. /home appears only after the reboot at the end, once
    # nix-darwin has commented out auto_home in /etc/auto_master.
    say "4/11 /etc/synthetic.conf"
    for LINE in "apps" "dt" "mnt" "home	Users" "run	private/var/run"; do
        sudo touch /etc/synthetic.conf
        grep -qxF "$LINE" /etc/synthetic.conf || printf '%s\n' "$LINE" | sudo tee -a /etc/synthetic.conf >/dev/null
    done
    /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t 2>/dev/null || true

    say "5/11 Homebrew"
    if [ ! -x "$BREW" ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$("$BREW" shellenv)"

    say "6/11 Nix (Lix installer)"
    if [ ! -x "$NIX" ]; then
        curl -sSf -L https://install.lix.systems/lix | sh -s -- install --no-confirm
    fi

    say "7/11 dotfiles"
    if [ ! -d "$DOTFILES/.git" ]; then
        # https: no ssh key for GitHub yet; the remote goes back to ssh below
        git clone "$REPO_HTTPS" "$DOTFILES"
        git -C "$DOTFILES" remote set-url origin "$REPO_SSH"
    fi

    # nix-darwin refuses to replace /etc files it does not recognise. A fresh
    # macOS has the stock ones; auto_master is pinned to lmini's edited copy.
    say "8/11 moving stock /etc files aside for nix-darwin"
    for F in /etc/zshrc /etc/bashrc /etc/zshenv /etc/auto_master; do
        if [ -f "$F" ] && [ ! -L "$F" ]; then
            sudo mv "$F" "$F.before-nix-darwin"
        fi
    done

    say "9/11 nix-darwin switch to .#$HOST (long: all of nixpkgs, casks, home-manager)"
    if command -v darwin-rebuild >/dev/null 2>&1; then
        (cd "$DOTFILES" && sudo darwin-rebuild switch --flake ".#$HOST")
    else
        (cd "$DOTFILES" && sudo "$NIX" --extra-experimental-features 'nix-command flakes' \
            run nix-darwin/master#darwin-rebuild -- switch --flake ".#$HOST")
    fi

    say "10/11 App Store apps"
    MAS_FAILED=()
    for ID in "${MAS_APPS[@]}"; do
        mas install "$ID" || MAS_FAILED+=("$ID")
    done
    [ "${#MAS_FAILED[@]}" -eq 0 ] || echo "mas could not install: ${MAS_FAILED[*]} (signed in to the App Store?)"

    # tailscale (brew formula, root daemon) and syncthing (brew, user agent):
    # both are installed by the switch, from darwinBrews.nix / lmini-darwin.nix
    say "11/11 services: Syncthing, Tailscale"
    "$BREW" services list | grep -q '^syncthing *started' || "$BREW" services start syncthing
    sudo "$BREW" services list | grep -q '^tailscale *started' || sudo "$BREW" services start tailscale
    # lmini: Tailscale SSH on, offered as exit node
    sudo tailscale up --ssh --advertise-exit-node --hostname="$HOST" || \
        echo "tailscale up failed — run it by hand: sudo tailscale up --ssh --advertise-exit-node --hostname=$HOST"

    cat <<EOF

Base done. By hand now:
  - REBOOT (synthetic.conf /home, auto_master, keyboard remap)
  - Syncthing, http://127.0.0.1:8384 : pair with umini/fmini..., accept the folders
    Sync -> ~/Sync  and  Notes -> ~/Notes ; then:  bash $0 post-sync
  - Tailscale admin console: approve the exit node; disable key expiry for $HOST
  - ~/.ssh keys from backup, then  gh auth login  and  claude  (log in)
  - set Finicky as default browser (System Settings > Desktop & Dock)
  - grant: Karabiner driver + input monitoring, PopClip/LaunchBar/Leader Key
    accessibility, herdr Full Disk Access (/opt/homebrew/bin/herdr)
  - apps not managed by brew/mas: reinstall from installers (list in this script)
EOF
}

post_sync() {
    preflight
    WS="$HOME/Sync/OpenClaw"
    [ -d "$WS/scripts/launchd" ] || die "$WS not there yet — wait for Syncthing"
    [ -f "$WS/credentials/secrets.env" ] || echo "warning: $WS/credentials/secrets.env missing"

    say "launchd agents for the scheduled Claude jobs"
    mkdir -p "$HOME/Library/Logs/claude" "$HOME/Library/LaunchAgents"
    for P in evening-summary memory-distill morning-schedule; do
        LABEL="local.claude.$P"
        cp "$WS/scripts/launchd/$LABEL.plist" "$HOME/Library/LaunchAgents/"
        launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
        launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/$LABEL.plist"
    done
    launchctl list | grep local.claude || true

    cat <<EOF

Post-sync done. By hand:
  - claude must be logged in (login Keychain) before 04:15, or the jobs fail
  - Calendar access for the morning job: run it once through launchd and allow
    the prompt:  launchctl kickstart gui/\$(id -u)/local.claude.morning-schedule
  - Claude's private memory is not synced: copy ~/.claude/projects/-Users-latb-Sync-OpenClaw/
    from a backup if wanted
EOF
}

# Apps on lmini (2026-10-26) that neither Homebrew nor `mas` installs — licensed
# or vendor installers, reinstall by hand (installers were on /apps):
#   audio:  Ableton Live 11/12 Suite, Arturia, Audio Hijack, AudioSwift, BitPerfect,
#           Plugin Alliance (PA-InstallationManager, bx_mastering), Components,
#           iLok License Manager, LUNA, UA Connect, Melodyne 5, Pianoteq 9, REAPER,
#           SpectraLayers 13, WaveLab 13, Tonalic, TOPPING Control Center, MIDI Monitor,
#           VoiceAssist, forScore, Henle Library
#   Apple Creator Studio: Final Cut Pro, Logic Pro, MainStage, Motion, Keynote, Pages
#   other:  Arq, Capture One 23, EasyFind, iA Presenter, iStat Menus, Ice, Thaw, Lyn,
#           Marked, Scrivener, Claude Usage, Microsoft Office/Teams/OneDrive,
#           TurboTax 2025, Xcode-beta

case "$STEP" in
    base) base ;;
    post-sync) post_sync ;;
    *) die "usage: $0 [base [hostname]] | post-sync" ;;
esac
