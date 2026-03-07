# ZMK Keymap Plan — Kinesis Advantage 360

## Goal

Create a portable keyboard configuration that preserves muscle memory across
Linux, macOS, and (occasionally) Windows. The primary friction point is the
Ctrl-vs-Cmd modifier difference on macOS for OS-level shortcuts.

## Current Workflow

- **Linux (primary):** Hyprland (Super for WM), tmux (Ctrl+b prefix), nvim, bash
- **macOS (secondary):** Aerospace (Alt for WM), tmux, nvim, Ghostty
- **Windows (rare):** SSH from another machine, minimal local use

Terminal tools (tmux, vim, shell) use Ctrl universally — no change needed.
The only divergence is OS-level shortcuts (copy, paste, etc.).

## Layer Design

### Layer 0: Default (Linux/Windows)

Standard QWERTY. No modifications to modifier keys.

```
Left thumb cluster:                Right thumb cluster:
┌───────┬───────┐                  ┌───────┬───────┐
│  Ctrl │  Alt  │                  │  Alt  │ Ctrl  │
├───────┼───────┤                  ├───────┼───────┤
│ Super │ Space │                  │ Enter │ Super │
├───────┼───────┤                  ├───────┼───────┤
│ Shift │  Del  │                  │ Bksp  │ Shift │
└───────┴───────┘                  └───────┴───────┘
```

Modifiers send exactly what they say. All Linux shortcuts work as expected:
- Ctrl+C/V/X/Z/A/S/F/T/W — standard shortcuts
- Super+1-9 — Hyprland workspaces
- Alt+hjkl — tmux pane navigation

### Layer 1: macOS

Activated by a toggle (see below). The ONLY change: **left and right Ctrl
keys send Cmd (GUI)**. Everything else is identical to Layer 0.

```
Left thumb cluster:                Right thumb cluster:
┌───────┬───────┐                  ┌───────┬───────┐
│ ⌘ Cmd │  Alt  │                  │  Alt  │ ⌘ Cmd │
├───────┼───────┤                  ├───────┼───────┤
│ Super │ Space │                  │ Enter │ Super │
├───────┼───────┤                  ├───────┼───────┤
│ Shift │  Del  │                  │ Bksp  │ Shift │
└───────┴───────┘                  └───────┴───────┘
```

This means your muscle memory is preserved:
- "Ctrl+C" (copy) → fingers hit same keys → sends Cmd+C on Mac ✓
- "Ctrl+V" (paste) → same fingers → Cmd+V ✓
- "Ctrl+Z" (undo) → same fingers → Cmd+Z ✓
- Alt+hjkl → still Alt → Aerospace tiling works ✓
- Ctrl+C in terminal → sends Cmd+C... wait.

### The Terminal Problem

On macOS, terminal apps need BOTH:
- Cmd+C → copy from terminal
- Ctrl+C → send SIGINT to process

If we remap Ctrl→Cmd at the keyboard level, we lose the ability to send
real Ctrl keystrokes to the terminal.

**Solution: Configure Ghostty (and any Mac terminal) to handle this.**

Ghostty on macOS already does the right thing by default:
- Cmd+C with text selected → copy
- Cmd+C with no selection → sends Ctrl+C (SIGINT) to the process
- Ctrl keybindings in apps (Ctrl+R for shell history, etc.) → still work
  because the physical Ctrl key is sending Cmd, but Ghostty interprets
  Cmd+R differently from Ctrl+R

**Actually, this is the real problem.** If physical Ctrl sends Cmd, then:
- Shell Ctrl+R (reverse search) → sends Cmd+R → won't work
- Shell Ctrl+A (beginning of line) → sends Cmd+A → select all in terminal
- Shell Ctrl+L (clear) → sends Cmd+L → address bar in browser
- Vim Ctrl+W (window commands) → sends Cmd+W → closes window

This breaks too many things. We need a smarter approach.

### Revised Layer 1: macOS (Smart Swap)

Instead of blindly swapping Ctrl→Cmd, we swap **Ctrl and Cmd positions**.
Physical Ctrl sends Cmd. Physical Super (which sends Cmd on Mac natively)
sends Ctrl.

```
Left thumb cluster (Mac layer):   Right thumb cluster (Mac layer):
┌───────┬───────┐                  ┌───────┬───────┐
│ ⌘ Cmd │  Alt  │                  │  Alt  │ ⌘ Cmd │
├───────┼───────┤                  ├───────┼───────┤
│ Ctrl  │ Space │                  │ Enter │ Ctrl  │
├───────┼───────┤                  ├───────┼───────┤
│ Shift │  Del  │                  │ Bksp  │ Shift │
└───────┴───────┘                  └───────┴───────┘
```

Now on the Mac layer:
- Physical Ctrl position → Cmd → copy/paste/cut/undo (OS shortcuts) ✓
- Physical Super position → Ctrl → terminal Ctrl+C/R/A/L, vim Ctrl+W ✓
- Alt stays Alt → Aerospace tiling ✓

Your fingers do the same thing for the same intent:
- "I want to copy" → hit the key where Ctrl is → works on both OSes
- "I want to kill a process" → hit the key where Super is (now Ctrl) → Ctrl+C
- "I want to switch workspace" → Alt+1-9 → Aerospace on Mac, different key
  on Linux (Super+1-9) but that's already a different modifier anyway

### Layer Toggle

**Fn + M** (for Mac) — toggle between Layer 0 and Layer 1.

This is a sticky toggle — press once to switch, stays until you press again.
You'll set it when you sit down at your Mac and forget about it.

The Kinesis 360 has persistent layer state across power cycles if you save
to the onboard profile, so you could also maintain separate profiles:
- Profile 1: Linux/Windows (Layer 0 default)
- Profile 2: Mac (Layer 1 default)

## Layer Summary

| Layer | Purpose     | Ctrl key sends | Super key sends | Alt key sends |
|-------|-------------|----------------|-----------------|---------------|
| 0     | Linux/Win   | Ctrl           | Super           | Alt           |
| 1     | macOS       | Cmd (GUI)      | Ctrl            | Alt           |

## Shortcuts Cheat Sheet (Both Platforms)

| Intent              | Physical keys        | Linux sends  | Mac sends    |
|---------------------|----------------------|-------------|-------------|
| Copy                | Ctrl pos + C         | Ctrl+C      | Cmd+C       |
| Paste               | Ctrl pos + V         | Ctrl+V      | Cmd+V       |
| Cut                 | Ctrl pos + X         | Ctrl+X      | Cmd+X       |
| Undo                | Ctrl pos + Z         | Ctrl+Z      | Cmd+Z       |
| Select all          | Ctrl pos + A         | Ctrl+A      | Cmd+A       |
| Save                | Ctrl pos + S         | Ctrl+S      | Cmd+S       |
| Find                | Ctrl pos + F         | Ctrl+F      | Cmd+F       |
| Close tab           | Ctrl pos + W         | Ctrl+W      | Cmd+W       |
| New tab             | Ctrl pos + T         | Ctrl+T      | Cmd+T       |
| Quit app            | Ctrl pos + Q         | (not std)   | Cmd+Q       |
| SIGINT              | Super pos + C        | Super+C (×) | Ctrl+C      |
| Shell history       | Super pos + R        | Super+R (×) | Ctrl+R      |
| Clear terminal      | Super pos + L        | Super+L (×) | Ctrl+L      |
| Beginning of line   | Super pos + A        | Super+A (×) | Ctrl+A      |
| Vim window cmd      | Super pos + W        | Super+W (×) | Ctrl+W      |
| Tiling WM focus     | Alt + hjkl           | Alt (tmux)  | Alt (Aero)  |
| Tiling WM workspace | Super pos + 1-9 (LX) | Super+1-9   | —           |
|                     | Alt + 1-9 (Mac)      | —           | Alt+1-9     |

Note: (×) marks combinations that don't do anything useful on Linux since
Super+letter triggers Hyprland bindings, not terminal commands. This is fine
because on Linux you already use Ctrl (the real Ctrl) for terminal shortcuts.

## Implementation

The Kinesis 360 uses Adv360-Pro-ZMK firmware. The keymap is configured via:

1. Fork https://github.com/KinesisCorporation/Adv360-Pro-ZMK
2. Edit `config/adv360.keymap`
3. Push to trigger GitHub Actions build
4. Flash the firmware via USB

See the `adv360.keymap` file in this directory for the actual keymap.

## Future Considerations

- **Colemak layer:** Could be added as Layer 2 if you decide to try it.
  Would need both a Linux-Colemak and Mac-Colemak variant, or a single
  Colemak layer with the Mac modifier swap on top (layer 2 + layer 1).
- **Gaming layer:** If needed, a layer that disables any home-row mods
  or special behaviors for clean WASD input.
- **Numpad layer:** The Kinesis already has this built in, but a custom
  one could be useful if the default doesn't suit your needs.
