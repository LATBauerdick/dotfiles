#!/bin/bash
# lite/link.sh — place the config links from users/user/links.txt without nix.
#
# Links point into this working tree, so an edit on a lite machine is an edit in git.
# Kinds: home → $HOME/<target>, xdg → ~/.config/<target>, lite → $HOME/<target>
# (lite-only entries; home-manager provides those itself on nix machines).
#
# An existing symlink is replaced; an existing real file or directory is moved aside
# to <target>.pre-lite-YYYYMMDD, never deleted. Re-running changes nothing.
#
#   lite/link.sh            # place links
#   lite/link.sh --dry-run  # show what would change
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$DOTFILES/users/user"
LIST="$SRC_DIR/links.txt"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d)"
DRY=""
[ "${1:-}" = "--dry-run" ] && DRY=1

run() { if [ -n "$DRY" ]; then echo "  would: $*"; else "$@"; fi; }

CHANGED=0
while read -r KIND TARGET SRC _; do
    case "$KIND" in
        ""|\#*) continue ;;
        home|lite) DEST="$HOME/$TARGET" ;;
        xdg) DEST="$CONFIG_HOME/$TARGET" ;;
        *) echo "links.txt: unknown kind '$KIND' for $TARGET" >&2; exit 1 ;;
    esac
    FROM="$SRC_DIR/$SRC"
    if [ ! -e "$FROM" ]; then
        echo "missing source: $FROM" >&2
        exit 1
    fi
    if [ -L "$DEST" ] && [ "$(readlink "$DEST")" = "$FROM" ]; then
        continue
    fi
    echo "$DEST -> $FROM"
    run mkdir -p "$(dirname "$DEST")"
    if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        echo "  keeping the existing file as $DEST.pre-lite-$STAMP"
        run mv "$DEST" "$DEST.pre-lite-$STAMP"
    fi
    run ln -sfn "$FROM" "$DEST"
    CHANGED=$((CHANGED + 1))
done < "$LIST"

[ "$CHANGED" -eq 0 ] && echo "all links in place"
exit 0
