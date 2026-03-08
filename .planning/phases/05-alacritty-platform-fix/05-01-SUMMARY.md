---
phase: 05-alacritty-platform-fix
plan: 01
subsystem: dotfiles
tags: [alacritty, stow, install.sh, zsh, cross-platform, toml]

# Dependency graph
requires:
  - phase: 03-cross-platform
    provides: install.sh with OS detection and stow loop, alacritty package structure

provides:
  - Alacritty base config with [general] import section and no font.size override
  - Platform TOML files at alacritty/platform/ (outside stow tree, placed by install.sh)
  - install.sh symlinks correct platform TOML (linux or macos) after stow
  - Clean zsh/.zshenv with only ZDOTDIR export (no PATH duplication)

affects: [cross-platform provisioning, alacritty terminal, zsh startup]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Platform file placement via install.sh ln -sf (not stow) for platform-specific configs"
    - "Platform TOMLs live outside stow tree at alacritty/platform/ to prevent cross-contamination"
    - "Alacritty [general] import section (not deprecated root-level import)"

key-files:
  created:
    - alacritty/platform/linux.toml
    - alacritty/platform/macos.toml
  modified:
    - alacritty/.config/alacritty/alacritty.toml
    - zsh/.zshenv
    - install.sh

key-decisions:
  - "Platform TOML files placed by install.sh via ln -sf (symlink), not stowed, so each machine only gets its own platform file"
  - "font.size removed from base alacritty.toml; platform files are the single source of truth for font size"
  - "Alacritty import moved from deprecated root level to [general] section per current Alacritty spec"
  - ".zshenv reduced to ZDOTDIR-only; PATH entries belong exclusively in shell/config.d/path"

patterns-established:
  - "Install-time placement pattern: configs that vary per platform and must not cross-contaminate go in <pkg>/platform/, placed by install.sh"

requirements-completed: [APP-01, APP-02, XPLAT-01]

# Metrics
duration: 7min
completed: 2026-03-08
---

# Phase 5 Plan 01: Alacritty Platform Fix Summary

**Alacritty restructured to place platform TOMLs via install.sh symlinks outside the stow tree, with [general] import and font.size owned by platform files only; PATH duplication in .zshenv eliminated.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-08T23:36:05Z
- **Completed:** 2026-03-08T23:43:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Created `alacritty/platform/linux.toml` and `alacritty/platform/macos.toml` outside the stow tree with explicit `font.size` values (9.0 and 13.0 respectively)
- Rewrote `alacritty.toml` base config: moved `import` under `[general]` section (fixing deprecated root-level syntax) and removed `font.size` so platform files are authoritative
- Updated `install.sh` to symlink the correct platform TOML after the stow loop, with only the base `alacritty.toml` in conflict checks
- Removed PATH duplication from `zsh/.zshenv` — `ZDOTDIR` is now the only export

## Task Commits

Each task was committed atomically:

1. **Task 1: Restructure Alacritty platform configs and fix PATH duplication** - `652ccc4` (feat)
2. **Task 2: Update install.sh for platform file placement and conflict checks** - `5dcf230` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `alacritty/platform/linux.toml` - Linux-specific font size (9.0), placed by install.sh
- `alacritty/platform/macos.toml` - macOS-specific font size (13.0) and option_as_alt, placed by install.sh
- `alacritty/.config/alacritty/alacritty.toml` - Base config with [general] import, no font.size
- `zsh/.zshenv` - Minimal: only ZDOTDIR export
- `install.sh` - Step 4.5 symlinks correct platform TOML; alacritty conflict check reduced to base only

## Decisions Made
- Platform TOMLs are symlinked by `install.sh` (not stowed) so running `stow alacritty` on Linux does not place `macos.toml` and vice versa
- `font.size` removed from base config entirely — base config loaded after imports would override platform values, making platform-specific sizing impossible
- `[general]` section used for import per current Alacritty TOML spec (root-level `import` is deprecated)
- `.zshenv` PATH entries removed — already present in `shell/.config/shell/config.d/path`, `.zshenv` is loaded very early and PATH manipulation belongs in the shared config layer

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. All verification checks passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Alacritty cross-platform config is now correct: Linux gets font size 9.0, macOS gets 13.0
- Running `./install.sh` on either platform will symlink the appropriate platform TOML
- Phase 5 (single plan) is complete

---
*Phase: 05-alacritty-platform-fix*
*Completed: 2026-03-08*
