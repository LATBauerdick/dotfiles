# Restore lmini on a fresh macOS

Bring a freshly installed Apple Silicon Mac back to what lmini has: user `latb`, nix-darwin + home-manager (`darwinConfigurations.lmini`), Homebrew casks/brews, App Store apps, Tailscale, Syncthing, the scheduled Claude jobs. Survey of lmini: 2026-10-26.

Run the blocks one at a time, in Terminal. Step 0 runs as `btal`, everything after as `latb`. Each block is safe to re-run.

## 0. Setup Assistant: btal

- Admin account, account name **`btal`** (gets UID 501, as on lmini)
- No Apple ID needed here

## 0b. Create latb (as btal)

latb on lmini is **UID 6170**, primary group **80 (admin)**, not the usual 501/staff: keep both, so file ownership on synced and backed-up data matches. `sysadminctl`, not `scutil` (that only does host names). `-adminUser btal` gives latb a secure token, so it can unlock FileVault.

```bash
sudo sysadminctl -addUser latb -fullName "LATBauerdick" -UID 6170 -GID 80 \
    -shell /bin/zsh -home /Users/latb -admin -password - \
    -adminUser btal -adminPassword -           # prompts for latb's, then btal's password
sudo createhomedir -c -u latb
dscl . -read /Users/latb UniqueID PrimaryGroupID NFSHomeDirectory UserShell
sysadminctl -secureTokenStatus latb           # check: ENABLED
```

Log out of btal, log in as **latb**, finish its first-login questions, and sign in to the Apple ID there (step 9, App Store, needs it). Everything below runs as latb.

## 1. Hostname

`make darwin` picks the config by hostname.

```bash
sudo scutil --set ComputerName lmini
sudo scutil --set LocalHostName lmini
sudo scutil --set HostName lmini
```

## 2. Command Line Tools and Rosetta

```bash
xcode-select --install          # finish the dialog before going on
sudo softwareupdate --install-rosetta --agree-to-license
```

## 3. /etc/synthetic.conf

Root-level mount points as on lmini; `/home` → `/Users`. The Lix installer adds its own `nix` line. `/home` appears only after the reboot in step 11 (nix-darwin comments out `auto_home` in `/etc/auto_master`). Background: `~/Sync/_configs/config/lmini/README.md`.

```bash
printf 'apps\ndt\nmnt\nhome\tUsers\nrun\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
cat /etc/synthetic.conf         # check: no duplicate lines
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
```

## 4. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 5. Nix (Lix installer)

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Open a **new terminal tab** afterwards so `nix` is on the PATH, and re-run the `brew shellenv` line from step 4 there.

## 6. dotfiles

Over https — no ssh key for GitHub yet; the remote goes back to ssh right away.

```bash
git clone https://github.com/LATBauerdick/dotfiles.git ~/dotfiles
git -C ~/dotfiles remote set-url origin git@github.com:LATBauerdick/dotfiles.git
```

## 7. Move stock /etc files aside

nix-darwin refuses to replace `/etc` files it does not recognise; `auto_master` is pinned to lmini's edited copy, so the stock one always blocks.

```bash
for f in /etc/zshrc /etc/bashrc /etc/zshenv /etc/auto_master; do
    [ -f "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "$f.before-nix-darwin"
done
```

## 8. First nix-darwin switch

Long: nixpkgs, every cask and brew, home-manager. Casks with `.pkg` installers ask for the password.

```bash
cd ~/dotfiles
sudo nix --extra-experimental-features 'nix-command flakes' \
    run nix-darwin/master#darwin-rebuild -- switch --flake .#lmini
```

If it stops on `/etc/nix/nix.conf` (written by the Lix installer): `sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin` and run it again. From now on it is just `make darwin`.

## 9. App Store apps

`homebrew.masApps` is off in `darwin.nix`, so these are not declarative. `mas` came with the switch.

```bash
mas install 937984704   # Amphetamine
mas install 1055511498  # Day One
mas install 775737590   # iA Writer
mas install 1136220934  # Infuse
mas install 1464122853  # NextDNS
mas install 361304891   # Numbers
mas install 6720708363  # Obsidian Web Clipper
mas install 6746662575  # Pixelmator Pro
mas install 1529448980  # Reeder
mas install 1491071483  # Tot
```

## 10. Syncthing and Tailscale

Both installed by the switch (`darwinBrews.nix`, `lmini-darwin.nix`). Tailscale is the brew formula as a root daemon; lmini runs Tailscale SSH and is an exit node.

```bash
brew services start syncthing
sudo brew services start tailscale
sudo tailscale up --ssh --advertise-exit-node --hostname=lmini   # opens a login URL
```

Tailscale admin console: approve the exit node, disable key expiry for lmini.

## 11. Reboot

For synthetic.conf (`/home`), `auto_master` and the caps-lock remap.

```bash
sudo shutdown -r now
```

## 12. Syncthing pairing

<http://127.0.0.1:8384>: add the other devices, accept the folders **Sync → `~/Sync`** and **Notes → `~/Notes`**. Wait until `~/Sync/OpenClaw` is complete before step 14.

## 13. Logins and keys

```bash
# ~/.ssh/id_* from backup first, then:
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
gh auth login
claude          # log in — the token lands in the login Keychain the launchd jobs use
```

## 14. Scheduled Claude jobs

```bash
mkdir -p ~/Library/Logs/claude
cp ~/Sync/OpenClaw/scripts/launchd/local.claude.*.plist ~/Library/LaunchAgents/
for p in evening-summary memory-distill morning-schedule; do
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.claude.$p.plist
done
launchctl list | grep local.claude
launchctl kickstart gui/$(id -u)/local.claude.morning-schedule   # allow the Calendar prompt
```

## 15. Permissions and defaults (GUI)

- Finicky as default browser: System Settings › Desktop & Dock › Default web browser
- Karabiner: driver extension + Input Monitoring
- Accessibility: PopClip, LaunchBar, Leader Key
- Full Disk Access: `/opt/homebrew/bin/herdr`, then `launchctl kickstart -k gui/$(id -u)/local.herdr.server`
- Claude's private memory is not synced: copy `~/.claude/projects/-Users-latb-Sync-OpenClaw/` from a backup if wanted

## 16. Install apps by hand

Not in Homebrew or the App Store — install from vendor installers (lmini kept them on its `/apps` volume; copy that before a wipe).

- Install apps: Ableton Live 11 Suite, Ableton Live 12 Suite, Arturia, Audio Hijack, AudioSwift, BitPerfect, Components, forScore, Henle Library, iLok License Manager, LUNA, Melodyne 5, MIDI Monitor, Pianoteq 9, Plugin Alliance (PA-InstallationManager, bx_mastering), REAPER, SpectraLayers 13, Tonalic, TOPPING Professional Control Center, UA Connect, VoiceAssist, WaveLab 13
- Install apps (Apple Creator Studio): Final Cut Pro, Logic Pro, MainStage, Motion, Keynote, Pages
- Install apps: Arq, Capture One 23, Claude Usage, EasyFind, iA Presenter, Ice, iStat Menus, Lyn, Marked, Microsoft Office (Word, Excel, PowerPoint, Outlook, OneNote), Microsoft Teams, OneDrive, Scrivener, Thaw, TurboTax 2025, Xcode-beta
