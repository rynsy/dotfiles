---
phase: 03-cross-platform-provisioning
plan: 03
subsystem: shell, terminal
tags: [powershell, alacritty, cross-platform, stow, toml]

requires:
  - phase: 03-cross-platform-provisioning-01
    provides: shared shell config in shell/.config/shell/config.d/

provides:
  - powershell/ stow package with cross-platform profile and alias parity
  - alacritty/ stow package with base config and platform-specific imports

affects: [03-cross-platform-provisioning-04]

tech-stack:
  added: [powershell-profile, alacritty-toml]
  patterns: [platform-include-pattern, stow-package-convention]

key-files:
  created:
    - powershell/.config/powershell/profile.ps1
    - alacritty/.config/alacritty/alacritty.toml
    - alacritty/.config/alacritty/linux.toml
    - alacritty/.config/alacritty/macos.toml
  modified: []

key-decisions:
  - "PowerShell profile standalone — mirrors zsh aliases but maintained independently, drift acceptable"
  - "Alacritty follows Ghostty platform-include pattern — base config imports linux.toml and macos.toml"
  - "gcm alias collision handled with Remove-Alias before function definition"

patterns-established:
  - "Platform-include pattern: base config imports platform files that are silently skipped if missing"
  - "PowerShell alias parity: functions for commands needing args, Set-Alias for simple mappings"

requirements-completed: [PSH-01, PSH-02, PSH-03, APP-01, APP-02, XPLAT-01]

duration: 2min
completed: 2026-03-08
---

# Phase 03 Plan 03: PowerShell Profile and Alacritty Config Summary

**PowerShell stow package with cross-platform aliases mirroring zsh, and Alacritty stow package with Ghostty-style platform includes**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-08T21:54:05Z
- **Completed:** 2026-03-08T21:55:40Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Created powershell/ stow package with profile.ps1 providing equivalent aliases to zsh (gcm, gcl, n, t, ta, dc, lab, proj, study, s, p)
- Created alacritty/ stow package with base config importing platform-specific TOML files, matching Ghostty's pattern
- Handled PowerShell gcm alias collision (built-in Get-Command) with Remove-Alias before redefinition
- Platform-aware directory shortcuts using $IsWindows/$IsLinux/$IsMacOS in PowerShell and import mechanism in Alacritty

## Task Commits

Each task was committed atomically:

1. **Task 1: Create powershell/ stow package with cross-platform profile** - `3a04f84` (feat)
2. **Task 2: Create alacritty/ stow package with platform includes** - `2d4435a` (feat)

## Files Created/Modified
- `powershell/.config/powershell/profile.ps1` - Cross-platform PowerShell profile with alias parity to zsh
- `alacritty/.config/alacritty/alacritty.toml` - Base Alacritty config with platform imports and shared font/padding settings
- `alacritty/.config/alacritty/linux.toml` - Linux-specific Alacritty settings (placeholder)
- `alacritty/.config/alacritty/macos.toml` - macOS-specific Alacritty settings (larger font, option_as_alt)

## Decisions Made
- PowerShell profile uses functions for aliases needing arguments (gcm, gcl, t, ta) and Set-Alias for simple mappings (n, dc, s, p) -- follows PowerShell conventions
- Alacritty font, padding, and cursor settings match Ghostty config for visual consistency across terminals
- macOS Alacritty overrides set font size to 13pt (vs 9pt on Linux) and enable option_as_alt for terminal keybinding compatibility

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- powershell/ and alacritty/ packages ready to be stowed
- Note: stowing alacritty may require removing existing ~/.config/alacritty/alacritty.toml first (or using --adopt)
- install.sh and install.ps1 updates are in Plan 03-04

## Self-Check: PASSED

All 4 created files verified on disk. Both task commits (3a04f84, 2d4435a) found in git log.

---
*Phase: 03-cross-platform-provisioning*
*Completed: 2026-03-08*
