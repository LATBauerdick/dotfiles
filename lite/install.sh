#!/bin/bash
# lite/install.sh — `make lite`: the dotfiles without nix, for machines where a full
# nix-darwin/home-manager setup is too heavy or unsupported (lbook, an Intel Mac:
# nixpkgs 26.11 dropped x86_64-darwin and Homebrew stopped building Intel bottles).
#
# Same configs as every other machine, via users/user/links.txt; CLI tools come as
# prebuilt release binaries through mise (users/user/mise/config.toml).
# Safe to re-run: every step skips what is already in place.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HOME/.local/bin"
MISE="$BIN/mise"

if ! xcode-select -p >/dev/null 2>&1 && [ "$(uname -s)" = Darwin ]; then
    echo "Xcode Command Line Tools missing (git, and a C compiler for nvim-treesitter):" >&2
    echo "  run  xcode-select --install  and then  make lite  again" >&2
    exit 1
fi

# 1. config links
"$DOTFILES/lite/link.sh"

# 2. oh-my-zsh — the zshrc sources ~/.oh-my-zsh/oh-my-zsh.sh
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

# 3. mise, as its own release binary
if [ ! -x "$MISE" ]; then
    case "$(uname -s)-$(uname -m)" in
        Darwin-x86_64) ASSET=macos-x64 ;;
        Darwin-arm64) ASSET=macos-arm64 ;;
        Linux-x86_64) ASSET=linux-x64 ;;
        Linux-aarch64) ASSET=linux-arm64 ;;
        *) echo "no mise build for $(uname -s)-$(uname -m)" >&2; exit 1 ;;
    esac
    VERSION="$(curl -fsSL https://api.github.com/repos/jdx/mise/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
    mkdir -p "$BIN"
    curl -fsSL -o "$MISE" "https://github.com/jdx/mise/releases/download/$VERSION/mise-$VERSION-$ASSET"
    chmod +x "$MISE"
fi

# 4. the CLI tools listed in ~/.config/mise/config.toml
MISE_YES=1 "$MISE" install
echo
echo "done — open a new shell. Update tools later with:  mise upgrade"
