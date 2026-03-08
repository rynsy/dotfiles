---
phase: 03-cross-platform-provisioning
plan: 01
subsystem: shell
tags: [stow, bash, zsh, cross-platform, uname, config-split]

# Dependency graph
requires:
  - phase: 01.1-bash-config
    provides: bash sources shared config from zsh/config.d
provides:
  - shell/ stow package with universal + platform-split config files
  - uname-conditional platform sourcing in zsh and bash
  - neutral ~/.config/shell/config.d/ location for any shell to reference
affects: [03-02, 03-03, 03-04, install-script]

# Tech tracking
tech-stack:
  added: []
  patterns: [platform-split config files (.linux/.darwin), uname case statement sourcing]

key-files:
  created:
    - shell/.config/shell/config.d/alias
    - shell/.config/shell/config.d/alias.linux
    - shell/.config/shell/config.d/alias.darwin
    - shell/.config/shell/config.d/env
    - shell/.config/shell/config.d/env.linux
    - shell/.config/shell/config.d/env.darwin
    - shell/.config/shell/config.d/path
    - shell/.config/shell/config.d/path.linux
    - shell/.config/shell/config.d/path.darwin
    - shell/.config/shell/config.d/secrets.encrypted
    - shell/.config/shell/config.d/.gitignore
  modified:
    - zsh/.config/zsh/.zshrc
    - bash/.bashrc

key-decisions:
  - "ls --color moved to alias.linux; ls -G added to alias.darwin (resolves research open question)"
  - "zig-wasm alias moved to alias.linux (emscripten is Linux-only)"
  - "env.darwin created as placeholder for future macOS env vars"

patterns-established:
  - "Platform split: base file + .linux + .darwin override files"
  - "Sourcing pattern: loop base files, case uname for platform files, then secrets"

requirements-completed: [SHELL-01, SHELL-02]

# Metrics
duration: 2min
completed: 2026-03-08
---

# Phase 3 Plan 1: Shared Shell Config Summary

**Extracted shell config from zsh/ into neutral shell/ stow package with Linux/Darwin platform splits and uname-conditional sourcing**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-08T21:48:31Z
- **Completed:** 2026-03-08T21:50:31Z
- **Tasks:** 2
- **Files modified:** 18 (11 created, 7 modified/deleted)

## Accomplishments
- Created shell/ stow package with 11 config files split into universal + platform overrides
- Moved `ls --color` to alias.linux, added `ls -G` to alias.darwin (resolving research open question)
- Updated .zshrc and .bashrc to source from ~/.config/shell/config.d/ with uname-conditional platform loading
- Removed old config.d files from zsh/ package (alias, env, path, secrets.encrypted, .gitignore)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create shell/ stow package with split config files** - `3af69cc` (feat)
2. **Task 2: Update zsh and bash sourcing, remove old config.d files** - `afa5110` (feat)

## Files Created/Modified
- `shell/.config/shell/config.d/alias` - Universal aliases (termbin, gcm, gcl, n=nvim, etc.)
- `shell/.config/shell/config.d/alias.linux` - Linux-only aliases (ls --color, wifi/nmcli, navicat, zig-wasm)
- `shell/.config/shell/config.d/alias.darwin` - macOS-only aliases (ls -G)
- `shell/.config/shell/config.d/env` - Universal env vars (EDITOR, VISUAL, LS_COLORS, ZMK BLE, DOTNET/VCPKG)
- `shell/.config/shell/config.d/env.linux` - Linux-only env vars (LUA_PATH, LUA_CPATH, XDG_SESSION_TYPE)
- `shell/.config/shell/config.d/env.darwin` - macOS env vars placeholder
- `shell/.config/shell/config.d/path` - Universal PATH entries (~/.local/bin, GEM, Composer, Dotnet, Pulumi, Cargo, Go)
- `shell/.config/shell/config.d/path.linux` - Linux-only paths (emscripten, Factorio)
- `shell/.config/shell/config.d/path.darwin` - macOS paths (brew shellenv)
- `shell/.config/shell/config.d/secrets.encrypted` - Ansible-vault encrypted secrets (copied from zsh/)
- `shell/.config/shell/config.d/.gitignore` - Ignores decrypted secrets file
- `zsh/.config/zsh/.zshrc` - Sourcing block updated to ~/.config/shell/config.d/
- `bash/.bashrc` - Sourcing block updated to ~/.config/shell/config.d/

## Decisions Made
- `ls --color` is Linux-specific (GNU ls flag) -- moved to alias.linux; `ls -G` added to alias.darwin for BSD ls
- zig-wasm alias classified as Linux-only since emscripten path is Linux-specific
- env.darwin created as empty placeholder with comment for future macOS env vars
- Root .gitignore glob `**/config.d/secrets` already covers new location -- no changes needed

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required

None - no external service configuration required. Run `stow --no-folding shell` to activate the new package.

## Next Phase Readiness
- shell/ stow package ready for inclusion in install.sh (Plan 03-03)
- Platform sourcing pattern established for any future platform-specific config
- Zsh and bash both verified sourcing from new location

---
*Phase: 03-cross-platform-provisioning*
*Completed: 2026-03-08*
