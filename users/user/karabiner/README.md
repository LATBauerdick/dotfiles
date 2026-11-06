# Karabiner-Elements

`~/.config/karabiner` is a **live** link to this folder (`links.txt`), so every Mac
runs the same `karabiner.json`. Karabiner rewrites that file whenever something
changes in its settings window — commit those changes like any other edit.

## Two kinds of keyboard (since 2026-11-05)

| | Apple keyboards | all other keyboards |
|---|---|---|
| which | built-in, Magic Keyboard (Bluetooth, vendor 76), Apple USB (vendor 1452) | Planck and other QMK boards, mechanical keyboards on the USB/BT adapter |
| hardware sends | QWERTY positions | Colemak letters (done in firmware) |
| Karabiner does | Caps Lock, Vi Mode (A), Raise (space), **Colemak Wide**, window tiling on the *physical* keys | window tiling on the Colemak *letters* — nothing else |
| rule file | `assets/complex_modifications/latb-apple-keyboards.json` | `assets/complex_modifications/latb-other-keyboards.json` |

Each rule carries the device condition itself (`device_if` / `device_unless` on
`is_built_in_keyboard`, vendor 1452, vendor 76), because Karabiner has no way to
assign a rule set to a device from its settings window: profiles are global, and
the Devices tab only offers on/off and simple key swaps. No keyboard needs to be
ignored. Both sets are enabled in `karabiner.json`; the files under `assets/` are
the same rules, for re-adding them in the UI.

**A new non-Apple keyboard that sends QWERTY** (not Colemak) belongs to the Apple
set: add its `{"vendor_id": N}` to the identifier list in every rule of both sets.

**Rule order matters.** Karabiner takes the first matching rule and never feeds
one rule's output into another, so the Apple tiling rule must stay above Colemak
Wide (it matches the physical keys j ; l k e c s).

## Window tiling

ctrl-option h/i/e/n (Colemak) = left/right/top/bottom half, with shift = the
two-window Arrange layouts, f/c/r = Fill/Center/Return. Karabiner sends macOS's
own fn-ctrl tiling shortcuts from its virtual keyboard, which has an fn key even
when the physical keyboard has none. This replaced `NSUserKeyEquivalents` in
`darwin.nix` (2026-11-04): option-i/e/n are dead keys on the U.S. layout, and
Gecko apps (Zen) swallowed them before the Window menu saw them.

## Devices

Karabiner leaves a device that also reports as a mouse alone by default. The
BT-500 adapter for the mechanical keyboard ("USB/BT Adapter for KB/Mouse",
Handheld Scientific, vendor 12457, product 2) is keyboard + mouse in one, so
`devices` turns "Modify events" on for it explicitly. Do the same for any other
combo receiver: `karabiner_cli --list-connected-devices` shows the identifiers.

## Kept from before

`devices` ignores Apple product 544 (vendor 1452), as fstu did before the shared
config. The other files in `assets/complex_modifications/` are the older
per-machine rule sets, not enabled.
