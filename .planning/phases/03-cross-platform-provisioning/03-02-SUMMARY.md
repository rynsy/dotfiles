---
phase: 03-cross-platform-provisioning
plan: 02
subsystem: infra
tags: [bash, homebrew, pacman, stow, cross-platform, provisioning]

# Dependency graph
requires:
  - phase: 03-01
    provides: shell/ stow package with shared config extracted from zsh/
provides:
  - Cross-platform install.sh supporting Arch Linux (pacman) and macOS (brew)
  - --minimal flag for CORE-only package installs
  - Updated PACKAGES stow array with shell, powershell, alacritty
  - Conflict checks for new stow package paths
affects: [03-03, 03-04]

# Tech tracking
tech-stack:
  added: [homebrew]
  patterns: [CORE/EXTRA package splitting, platform-specific package manager dispatch, cask separation]

key-files:
  created: []
  modified: [install.sh]

key-decisions:
  - "Cask installs use || true with warning to prevent script failure if cask name varies"
  - "All stow packages deployed on all platforms regardless of OS -- configs self-filter via platform includes"
  - "Homebrew auto-install checks both /opt/homebrew and /usr/local paths for Apple Silicon and Intel Macs"

patterns-established:
  - "CORE/EXTRA split: CORE always installed, EXTRA gated by --minimal flag"
  - "Platform arrays: separate CORE_PACMAN/CORE_BREW and EXTRA_PACMAN/EXTRA_BREW/EXTRA_CASKS"

requirements-completed: [PROV-01, PROV-02, PROV-04]

# Metrics
duration: 1min
completed: 2026-03-08
---

# Phase 3 Plan 2: Cross-Platform Install Script Summary

**Cross-platform install.sh with pacman/brew dispatch, --minimal CORE-only flag, and Homebrew auto-install on macOS**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-08T21:54:02Z
- **Completed:** 2026-03-08T21:55:09Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- install.sh detects OS via `uname -s` and dispatches to pacman (Linux) or brew (Darwin)
- `--minimal` flag limits installation to 7 CORE packages (stow, zsh, fzf, zoxide, tmux, neovim, git)
- Homebrew auto-installed on macOS if missing, with `brew shellenv` eval for immediate availability
- PACKAGES stow array expanded: added shell, powershell, alacritty alongside existing packages
- Conflict checks added for shell/, powershell/, and alacritty/ config paths
- Post-install secrets path updated from zsh/ to shell/ location
- Unsupported OS (not Linux or Darwin) exits early with clear error message

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite install.sh with platform detection and --minimal flag** - `43c2078` (feat)

## Files Created/Modified
- `install.sh` - Cross-platform bootstrap script with OS detection, --minimal flag, and brew/pacman support

## Decisions Made
- Cask installs wrapped with `|| true` and warning message so script continues if a cask name is wrong or unavailable
- All stow packages deployed on all platforms -- configs self-filter via platform includes (following ghostty pattern)
- Homebrew shellenv eval checks both `/opt/homebrew/bin/brew` (Apple Silicon) and `/usr/local/bin/brew` (Intel) paths

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- install.sh is ready for cross-platform provisioning
- Plan 03-03 (install.ps1 for Windows) can proceed independently
- Plan 03-04 (Alacritty config) can proceed -- alacritty is in PACKAGES and conflict checks

---
## Self-Check: PASSED

- install.sh: FOUND
- 03-02-SUMMARY.md: FOUND
- Commit 43c2078: FOUND

---
*Phase: 03-cross-platform-provisioning*
*Completed: 2026-03-08*
