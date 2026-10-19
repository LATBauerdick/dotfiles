#!/bin/bash
# lite/apps.sh — install the GUI apps listed in lite/apps.txt (macOS only).
# A .dmg holding the app is copied to /Applications; one holding a .pkg is run
# through `sudo installer` (asks for the password).
# Safe to re-run: an app already in /Applications is skipped.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$DOTFILES/lite/apps.txt"

[ "$(uname -s)" = Darwin ] || exit 0

WORK="$(mktemp -d)"
MNT=""
cleanup() {
    [ -n "$MNT" ] && hdiutil detach -quiet "$MNT" || true
    rm -rf "$WORK"
}
trap cleanup EXIT

while IFS='|' read -r APP URL; do
    APP="$(echo "$APP" | sed 's/^ *//; s/ *$//')"
    URL="$(echo "$URL" | sed 's/^ *//; s/ *$//')"
    [ -z "$APP" ] || [ "${APP:0:1}" = "#" ] && continue
    if [ -d "/Applications/$APP" ]; then
        echo "  $APP: present"
        continue
    fi
    echo "  $APP: downloading $URL"
    curl -fsSL -o "$WORK/app.dmg" "$URL"
    MNT="$(hdiutil attach -nobrowse -readonly -noverify "$WORK/app.dmg" | awk -F'\t' '/\/Volumes\//{print $NF}' | tail -1)"
    PKG="$(find "$MNT" -maxdepth 1 -name '*.pkg' | head -1)"
    if [ -d "$MNT/$APP" ]; then
        # refuse anything Gatekeeper would not open
        spctl --assess --type execute "$MNT/$APP"
        ditto "$MNT/$APP" "/Applications/$APP"
    elif [ -n "$PKG" ]; then
        # an installer package (drivers, system extensions): needs sudo
        pkgutil --check-signature "$PKG" | grep "signed by a developer certificate issued by Apple for distribution" >/dev/null
        spctl --assess --type install "$PKG"
        sudo installer -pkg "$PKG" -target /
    else
        echo "  $APP: neither the app nor a .pkg in the disk image" >&2
        exit 1
    fi
    hdiutil detach -quiet "$MNT"
    MNT=""
    rm -f "$WORK/app.dmg"
    echo "  $APP: installed"
done < "$LIST"
