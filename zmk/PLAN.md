# ZMK Keymap Plan — Kinesis Advantage 360 Pro

## Goal

Create a portable keyboard configuration that preserves muscle memory across
Linux, macOS, and (occasionally) Windows. The primary friction point is the
Ctrl-vs-Cmd modifier difference on macOS for OS-level shortcuts.

## Current Setup

- **Fork:** github.com/rynsy/Adv360-Pro-ZMK (needs upstream sync)
- **Custom macros:** quotes, double-quotes, brackets, braces on Fn layer
- **Homerow mods:** defined but not actively used on base layer
- **Profiles:** 5 Bluetooth profiles available (Mod+1-5)

## Current Workflow

- **Linux (primary):** Hyprland (Super for WM), tmux (Ctrl+b prefix), nvim, bash
- **macOS (secondary):** Aerospace (Alt for WM), tmux, nvim, Ghostty
- **Windows (rare):** SSH from another machine, minimal local use

## Actual Keyboard Layout — Thumb Clusters

```
LEFT THUMB CLUSTER:              RIGHT THUMB CLUSTER:

        Ctrl    Alt                  GUI/⊞    Ctrl
    Bksp    Home                          PgUp
    Del     End                  Enter    Space
                                          PgDn
```

Full base layer matrix (from current keymap):
```
LEFT HALF:
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│  =  │  1  │  2  │  3  │  4  │  5  │ Kp  │
├─────┼─────┼─────┼─────┼─────┼─────┤Toggle│
│ Tab │  Q  │  W  │  E  │  R  │  T  ├─────┤
├─────┼─────┼─────┼─────┼─────┼─────┤     │
│ Esc │  A  │  S  │  D  │  F  │  G  │     │
├─────┼─────┼─────┼─────┼─────┼─────┤     │
│Shift│  Z  │  X  │  C  │  V  │  B  │     │
├─────┼─────┼─────┼─────┼─────┼─────┘     │
│ Fn  │  `  │Caps │  ←  │  →  │            │
└─────┴─────┴─────┴─────┴─────┘            │
                          Ctrl  Alt        │
                      Bksp    Home         │
                      Del     End          │
                                           │
RIGHT HALF:                                │
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┤
│ Mod │  6  │  7  │  8  │  9  │  0  │  -  │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│     │  Y  │  U  │  I  │  O  │  P  │  \  │
├─────┤─────┼─────┼─────┼─────┼─────┼─────┤
│     │  H  │  J  │  K  │  L  │  ;  │  '  │
├─────┤─────┼─────┼─────┼─────┼─────┼─────┤
│     │  N  │  M  │  ,  │  .  │  /  │Shift│
│     └─────┼─────┼─────┼─────┼─────┼─────┤
│           │  ↑  │  ↓  │  [  │  ]  │ Fn  │
│           └─────┴─────┴─────┴─────┴─────┘
│        GUI/⊞   Ctrl
│             PgUp
│        Enter   Space
│             PgDn
```

Key observations:
- **No GUI/Super key on the left** — only Ctrl and Alt
- **GUI/Super is only on the right** — paired with right Ctrl
- **Home/End on left thumb**, PgUp/PgDn on right thumb
- **Fn keys** are pinky keys (bottom corners), momentary layer shift
- **Mod key** is top-right, accesses BT profiles, bootloader, etc.

## Layer Design

### Layer 0: Default (Linux/Windows) — No changes needed

All modifiers are stock. This is what you use today:
- Left Ctrl + letter → OS shortcuts (copy, paste, etc.) AND terminal Ctrl
- Right GUI + 1-9 → Hyprland workspaces (but physically awkward)
- Alt + hjkl → tmux pane navigation (no prefix needed)

Note: On Linux, you likely use Super+1-9 with a different hand position than
the right thumb GUI key. Since Hyprland binds Super to workspace switching,
and the only GUI key is on the right thumb, you're probably reaching for it
with your right thumb while hitting numbers with your left hand. This works
but isn't ideal.

### Layer 4: macOS

Added as a new layer (layers 1-3 are Keypad, Fn, Mod). The changes:

```
LEFT THUMB CLUSTER:              RIGHT THUMB CLUSTER:
  (Mac layer)                      (Mac layer)

        Cmd     Alt                  Ctrl     Cmd
    Bksp    Home*                         PgUp*
    Del     End*                 Enter    Space
                                          PgDn*
```

Changes from default:
- **Left Ctrl → Cmd (LGUI):** OS shortcuts stay on the same finger
- **Right GUI → Ctrl (RCTRL):** Terminal Ctrl moves to where GUI was
- **Right Ctrl → Cmd (RGUI):** Right side also has Cmd for shortcuts
- Home/End → Cmd+Left/Cmd+Right (via macro): fixes line navigation
- PgUp/PgDn: consider remapping to Option+Up/Down for Mac behavior

### The Terminal Problem (and solution)

On macOS, terminal apps need BOTH Cmd (for copy/paste) and Ctrl (for
SIGINT, history search, etc.). The swap handles this:

| Physical key | Linux sends | Mac layer sends | Purpose on Mac |
|---|---|---|---|
| Left Ctrl | Ctrl | Cmd | OS shortcuts (copy, paste, save...) |
| Left Alt | Alt | Alt | Aerospace tiling WM |
| Right GUI | GUI/Super | Ctrl | Terminal control (Ctrl+C, Ctrl+R...) |
| Right Ctrl | Ctrl | Cmd | OS shortcuts (right hand) |

Your muscle memory:
- "Copy" → left thumb Ctrl + C → Cmd+C on Mac ✓
- "Kill process" → right thumb (was GUI, now Ctrl) + C → Ctrl+C ✓
- "History search" → right thumb + R → Ctrl+R ✓
- "Aerospace focus" → Alt + hjkl → unchanged ✓
- "tmux prefix" → Ctrl+b → Cmd+b... WAIT

### The tmux prefix problem

If left Ctrl sends Cmd on Mac, then Ctrl+b (tmux prefix) becomes Cmd+b,
which tmux won't recognize.

**Solutions (pick one):**
1. **Use right thumb (now Ctrl) + b** for tmux prefix on Mac. Slight
   muscle memory shift but keeps everything else clean.
2. **Remap tmux prefix to Cmd+b on Mac** in tmux.conf:
   `if-shell "uname | grep -q Darwin" "set -g prefix C-b"` — actually
   Cmd+b won't register as C-b. This won't work.
3. **Add Ghostty keybind** to translate Cmd+b → Ctrl+b. This is the
   cleanest solution — handle it in the terminal, not the keyboard.

**Recommended: Option 3.** Add to Ghostty config (Mac only):
```
keybind = cmd+b=text:\x02
```
This makes Cmd+b send the Ctrl+b byte (0x02) to the terminal. Your left
thumb hits the same key, tmux gets the same signal. Other Cmd+letter
combos that need to reach the terminal can be handled the same way.

Alternatively, just get used to using right thumb for tmux prefix on Mac.
It's one keybind to relearn.

### Home/End Fix for macOS

macOS uses Cmd+Left/Right for line navigation, not Home/End.
On the Mac layer, we remap:
- **Home → Cmd+Left** (beginning of line)
- **End → Cmd+Right** (end of line)

These are implemented as ZMK macros that press GUI+Arrow.

### Layer Toggle

**Mod + M** — toggle Mac layer on/off.

Since the Kinesis 360 supports 5 Bluetooth profiles, the practical
workflow is:
- **Profile 1:** Paired with Linux desktop → Mac layer OFF
- **Profile 2:** Paired with MacBook → Mac layer ON

Toggle once when switching machines. Or, if you always use the same
profile per machine, you can set it once and forget it.

## Layer Summary

| Layer | Name    | Purpose | Left Ctrl | Right GUI | Right Ctrl |
|-------|---------|---------|-----------|-----------|------------|
| 0     | Default | Linux   | Ctrl      | GUI       | Ctrl       |
| 1     | Keypad  | Numpad  | (stock)   | (stock)   | (stock)    |
| 2     | Fn      | F-keys  | (stock)   | (stock)   | (stock)    |
| 3     | Mod     | BT/LED  | (stock)   | (stock)   | (stock)    |
| 4     | macOS   | Mac     | Cmd       | Ctrl      | Cmd        |

## Shortcuts Cheat Sheet (Both Platforms)

| Intent            | Physical key     | Linux sends | Mac sends  |
|-------------------|------------------|-------------|------------|
| Copy              | L.Ctrl + C       | Ctrl+C      | Cmd+C      |
| Paste             | L.Ctrl + V       | Ctrl+V      | Cmd+V      |
| Cut               | L.Ctrl + X       | Ctrl+X      | Cmd+X      |
| Undo              | L.Ctrl + Z       | Ctrl+Z      | Cmd+Z      |
| Select all        | L.Ctrl + A       | Ctrl+A      | Cmd+A      |
| Save              | L.Ctrl + S       | Ctrl+S      | Cmd+S      |
| Find              | L.Ctrl + F       | Ctrl+F      | Cmd+F      |
| Close tab         | L.Ctrl + W       | Ctrl+W      | Cmd+W      |
| SIGINT            | L.Ctrl + C (LX)  | Ctrl+C      | —          |
|                   | R.GUI + C (Mac)  | —           | Ctrl+C     |
| Shell history     | L.Ctrl + R (LX)  | Ctrl+R      | —          |
|                   | R.GUI + R (Mac)  | —           | Ctrl+R     |
| tmux prefix       | L.Ctrl + b       | Ctrl+b      | Cmd+b *    |
| Beginning of line | Home key         | Home        | Cmd+Left   |
| End of line       | End key          | End         | Cmd+Right  |
| Tiling WM         | Alt + hjkl       | Alt (tmux)  | Alt (Aero) |
| WM workspace      | R.GUI + 1-9 (LX) | Super+1-9  | —          |
|                   | Alt + 1-9 (Mac)  | —           | Alt+1-9    |

\* tmux prefix via Ghostty keybind: `keybind = cmd+b=text:\x02`

## Implementation Steps

1. **Sync fork** with upstream KinesisCorporation/Adv360-Pro-ZMK
2. **Edit config/adv360.keymap** — add Mac layer (layer 4)
3. **Add Home/End macros** for Cmd+Arrow behavior
4. **Push to GitHub** — Actions will build firmware
5. **Flash both halves** via USB bootloader
6. **Add Ghostty Mac keybind** for tmux prefix: `keybind = cmd+b=text:\x02`
7. **Test** on both Linux and Mac

## Future Considerations

- **Colemak layer:** Layer 5, with a Mac-Colemak variant as layer 6
  (or use conditional layers to combine Colemak + Mac modifier swap)
- **Gaming layer:** Disable homerow mods, clean WASD
- **Numpad tweaks:** Layer 1 (Keypad) is already stock, customize if needed
