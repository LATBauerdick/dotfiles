# Set up fair (mac-149207) on a fresh macOS

Bring the FNAL MacBook Air M5 from a fresh, MDM-enrolled macOS to the usual setup: user `bauerdic`, nix-darwin + home-manager (`darwinConfigurations.fair`), Homebrew casks/brews, Syncthing, a per-machine ssh key, Claude Code, Hermes on the shared profile. Written 2026-11-24 after the espresso-spill repair.

Starting point: logged in as `bauerdic`, iCloud signed in, Tailscale app installed and connected.

Run the blocks one at a time, in Terminal, as bauerdic. Each block is safe to re-run.

Differences from before the repair: the home is **`/Users/bauerdic`** (was `/home/bauerdic`; no `/home` link at all — sandboxed daemons and the Claude app both want the physical path), and fair has its own flake output `.#fair` instead of the shared `m1mac.bauerdic`.

## 0. uid 6170

MDM creates bauerdic with the next free uid (501/502); the fleet uses **6170** for it, so file ownership matches on external disks and backups. Do it first, while almost nothing belongs to the account. It runs from bauerdic's own Terminal (MDM allows no second admin at the console).

Give Terminal **Full Disk Access** first (System Settings › Privacy & Security), else the ownership change fails on `~/Library/Mail`, Safari and the like. Quit every other app.

```bash
id -u; dscl . -list /Users UniqueID | grep -w 6170      # current uid; the grep must print nothing
```

Open a **root shell first** and stay in it for the next three blocks. Once the uid has changed, the old shell's uid belongs to nobody and `sudo` answers "you do not exist in the passwd database" (seen 2026-11-24).

```bash
sudo -s
```

```bash
OLD=$(id -u bauerdic); echo $OLD; dscl . -change /Users/bauerdic UniqueID $OLD 6170
```

Everything the old uid owned, in the home and outside it. "Operation not permitted" on a few system-protected files is harmless:

```bash
find /System/Volumes/Data -xdev -user $OLD -exec chown -h 6170 {} +; stat -f %u /Users/bauerdic      # 6170
```

Reboot at once: running processes still carry the old uid.

```bash
shutdown -r now
```

If the root shell is gone before the `chown` ran: `login bauerdic` in Terminal gives a shell with the new uid, where `sudo` works again; put the old number (`stat -f %u ~`) in place of `$OLD`.

After logging in again, the second command must print nothing:

```bash
id -u; find ~ -xdev ! -user 6170 2>/dev/null | head
```

FileVault and SecureToken hang on the account's GeneratedUID, not the numeric uid, so login and disk unlock should be unaffected; the primary group stays `staff` (20). ⚠️ Not tested on a Jamf / Platform SSO Mac. To undo: the same `dscl` line with the numbers swapped, and the reverse `chown`.

## 0b. Check the starting point

```bash
id -un; id -u; echo $HOME; hostname -s; uname -m
```

Expect `bauerdic`, `6170`, `/Users/bauerdic`, `MAC-149207` (pinned by MDM — do not change it; `make darwin` maps it to `fair`), `arm64`.

## 1. Command Line Tools and Rosetta

```bash
xcode-select --install          # finish the dialog before going on
```

```bash
sudo softwareupdate --install-rosetta --agree-to-license
```

## 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 3. Nix (Lix installer)

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Open a **new terminal tab** afterwards so `nix` is on the PATH, and re-run the `brew shellenv` line from step 2 there.

## 4. dotfiles

Over https — no ssh key for GitHub yet; the remote goes back to ssh right away.

```bash
git clone https://github.com/LATBauerdick/dotfiles.git ~/dotfiles
```

```bash
git -C ~/dotfiles remote set-url origin git@github.com:LATBauerdick/dotfiles.git
```

```bash
ls ~/dotfiles/machines/fair-darwin.nix      # must exist: the fair config was added 2026-11-24
```

If that file is missing, the commit has not been pushed from lmini yet. Push there, then `git -C ~/dotfiles pull https://github.com/LATBauerdick/dotfiles.git master`.

## 5. Move stock /etc files aside

nix-darwin refuses to replace `/etc` files it does not recognise.

```bash
for f in /etc/zshrc /etc/bashrc /etc/zshenv; do [ -f "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "$f.before-nix-darwin"; done; ls /etc/*.before-nix-darwin
```

## 6. First nix-darwin switch

Long: nixpkgs, every cask and brew, home-manager. Casks with `.pkg` installers ask for the password.

```bash
cd ~/dotfiles && sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/master#darwin-rebuild -- switch --flake .#fair
```

If it stops on `/etc/nix/nix.conf` (written by the Lix installer), move it aside and run the switch again:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

If a cask stops the bundle because the app is already there (something MDM or Self Service installed), delete that app or comment the cask out for now, and re-run. From now on it is just `make darwin` in `~/dotfiles`.

⚠️ The switch installs DEVONthink. **Do not open it** — see step 13.

Open a **new terminal window** now: zsh, prompt, `nix`, `brew`, `gh`, `syncthing` and `claude` all come from this step.

## 7. Tailscale

Already installed. In the app: Start at login, Install CLI, Allow local network access. Do not offer an exit node (a node that offers one cannot use one).

Admin console: the pre-repair node `mac-149207` (100.92.197.61) is probably still listed. If the new one came up as `mac-149207-1`, delete the stale node and rename the new one to `mac-149207`; disable key expiry.

## 8. Syncthing

`aiws` needs its `.stignore` **before** the folder is accepted (syncthing never syncs `.stignore`). Same text as on the other peers:

```bash
mkdir -p ~/aiws ~/Sync ~/Notes && cat > ~/aiws/.stignore <<'EOF'
// aiws — the AI workspace as its own syncthing folder (2026-11-01; was ~/Sync/OpenClaw).
// This file is per-device (syncthing does not sync .stignore); keep the copies identical.
/.git
(?d).DS_Store
// zettel index lives in ~/Library/Caches/claude/zettel-index since the move; guard against a stray rebuild here
/.openclaw/zettelkasten-index
EOF
```

`~/Sync` and `~/Notes` get theirs in step 10: it is `#include stignore`, and the included file only arrives with the first sync.

```bash
brew services start syncthing
```

```bash
syncthing device-id || syncthing --device-id
```

That is a **new** device ID; the pre-repair one is dead.

1. On umini (the syncthing master) and on lmini: remove the old device `fair`, add the new ID as `fair`, share **Sync**, **Notes** and **aiws** with it.
2. On fair, at <http://127.0.0.1:8384>: accept the devices, then the folders — Sync → `~/Sync`, Notes → `~/Notes`, aiws → `~/aiws`. Check each path before saving.
3. Wait for "Up to Date" on all three before step 10. Notes and Sync are large; steps 9 and 11 can run meanwhile.

## 9. ssh key and GitHub

One key per machine (since 2026-10-19).

```bash
ssh-keygen -t ed25519 -C "bauerdic@fair $(date +%Y-%m-%d)"
```

```bash
gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
```

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --title "fair ($(date +%Y-%m-%d))"
```

If that is refused for a missing scope: `gh auth refresh -h github.com -s admin:public_key`, then again.

```bash
ssh -T git@github.com           # "Hi LATBauerdick! You've successfully authenticated"
```

```bash
cat ~/.ssh/id_ed25519.pub       # for lmini's authorized_keys and the SSH-key inventory note
```

## 10. After the first sync

```bash
ls ~/aiws/CLAUDE.md ~/aiws/credentials/secrets.env ~/Sync/stignore ~/Notes/stignore ~/Sync/hermes-profile/config.yaml
```

All five must be there. Then give every folder with a synced `stignore` its local `.stignore`:

```bash
bash ~/aiws/scripts/syncthing-stignore.sh apply
```

Open a new terminal: zshrc now finds `~/aiws/credentials/secrets.env`.

```bash
echo ${KAGI_API_KEY:+set}       # "set"
```

## 11. Claude Code

```bash
cd ~/aiws && claude             # log in
```

Claude's private memory (`~/.claude/projects/`) is per machine and starts empty here. The hooks and the `local.claude.*` launchd jobs are lmini's; nothing to install on fair.

## 12. Hermes

The shared profile lives in `~/Sync/hermes-profile/`; each Mac's `~/.hermes/<name>` is a symlink into it.

```bash
mkdir -p ~/.hermes && for n in SOUL.md config.yaml .env shell-hooks-allowlist.json memories skills scripts hooks plugins; do [ -e ~/Sync/hermes-profile/$n ] && ln -sfn ~/Sync/hermes-profile/$n ~/.hermes/$n; done; ls -l ~/.hermes
```

The program itself (`hermes-agent/`, `bin/`, the launcher) is per machine and was always copied between Macs, not installed from upstream (v0.21.1 with one local commit). ftop has the only copy left. **On ftop:**

```bash
tar -czf ~/Desktop/hermes-build.tgz -C ~/.hermes hermes-agent bin -C ~/.local/bin hermes
```

AirDrop it to fair, then **on fair**:

```bash
mkdir -p ~/.local/bin && tar -xzf ~/Downloads/hermes-build.tgz -C ~/.hermes && mv ~/.hermes/hermes ~/.local/bin/hermes
```

ftop's home is `/home/bauerdic`, fair's is `/Users/bauerdic`, so the baked-in path has to be rewritten — the recipe that worked for lair on 2026-09-26. ⚠️ **Not tested on fair.**

```bash
grep -rIl --null /home/bauerdic ~/.hermes/hermes-agent ~/.hermes/bin ~/.local/bin/hermes | xargs -0 sed -i '' 's|/home/bauerdic|/Users/bauerdic|g'
```

```bash
find ~/.hermes/hermes-agent -type d -name __pycache__ -prune -exec rm -rf {} +
```

```bash
find ~/.hermes/hermes-agent ~/.hermes/bin ~/.local/bin/hermes -type l | while IFS= read -r l; do t="$(readlink "$l")"; case "$t" in /home/bauerdic/*) ln -sfn "/Users/bauerdic${t#/home/bauerdic}" "$l";; esac; done
```

```bash
find ~/.hermes/hermes-agent ~/.hermes/bin -type l ! -exec test -e {} \; -print     # dangling links: tools ftop has and fair lacks
```

```bash
hermes --version                # 0.21.1
```

If it does not start, the venv's interpreter is the first thing to look at (a uv-managed python under ftop's home that was not in the tarball). `auth.json` is per machine: start `hermes` in `~/aiws` and log in.

## 13. DEVONthink

Do **not** open DEVONthink before its databases are in place. A new sync peer is seeded by **copying the `.dtBase2` files from lmini**, never by downloading from a sync store; only then does fair join `DTsync`. Do this with Claude on lmini.

## 14. Reboot

For the caps-lock remap and the login-time defaults.

```bash
sudo shutdown -r now
```

## 15. Permissions and defaults (GUI)

- Finicky as default browser: System Settings › Desktop & Dock › Default web browser
- Karabiner: driver extension + Input Monitoring
- Accessibility: PopClip, LaunchBar, Leader Key
- Rex: open Rex.app once (registers its launchd server)
- App Store apps are not declarative; lmini's list is in `restore-lmini.md`, step 9
- Remote Login: leave it off (the Tailscale app cannot serve Tailscale SSH; fair is maintained from a Claude session on fair)
