---
phase: 06-gap-corrections
plan: 01
subsystem: infra
tags: [homebrew, macos, path, shell, requirements]

# Dependency graph
requires:
  - phase: 05-alacritty-platform-fix
    provides: "v1.0 milestone complete; gap audit identified ZMK-03/04 descope and Intel Mac PATH bug"
provides:
  - "Intel Mac Homebrew PATH support via dual-arch if/elif guard in path.darwin"
  - "Accurate REQUIREMENTS.md v1 coverage summary reflecting 14 complete + 2 descoped"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns: ["dual-arch Homebrew PATH detection using file existence check (not uname -m)"]

key-files:
  created: []
  modified:
    - shell/.config/shell/config.d/path.darwin
    - .planning/REQUIREMENTS.md

key-decisions:
  - "Use file existence check ([ -f /opt/homebrew/bin/brew ]) rather than uname -m for arch detection — tests what matters directly"
  - "ZMK-03/04 coverage count corrected to '14 complete, 2 descoped' — not marked complete since they were never delivered"

patterns-established:
  - "Homebrew PATH pattern: if/elif binary existence guard, Apple Silicon first, Intel fallback — same as install.sh reference implementation"

requirements-completed:
  - ZMK-03
  - ZMK-04
  - PROV-02

# Metrics
duration: 2min
completed: 2026-03-09
---

# Phase 06 Plan 01: Gap Corrections Summary

**Dual-arch Homebrew PATH guard in path.darwin (Intel Mac fallback) and accurate REQUIREMENTS.md v1 coverage count (14 complete, 2 descoped)**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-09T20:34:28Z
- **Completed:** 2026-03-09T20:35:42Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- path.darwin now works on Intel Macs — if/elif guard tries /opt/homebrew first, falls back to /usr/local; no silent failure via `|| true`
- REQUIREMENTS.md v1 coverage summary corrected from "all complete" to "14 complete, 2 descoped to v2 (ZMK-03, ZMK-04)"
- ZMK-03/04 remain in v2 section without checkboxes and show "Deferred" in traceability table (unchanged)

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix path.darwin Intel Mac Homebrew fallback** - `ba98ea1` (fix)
2. **Task 2: Correct REQUIREMENTS.md coverage summary for ZMK-03/04** - `e2ecc98` (docs)

## Files Created/Modified

- `shell/.config/shell/config.d/path.darwin` - Replaced single eval+suppression line with dual-arch if/elif guard
- `.planning/REQUIREMENTS.md` - Updated coverage summary line; updated Last updated date

## Decisions Made

- File existence check used instead of `uname -m` — tests the binary directly, architecture-agnostic, same pattern as install.sh lines 58-62
- No `2>/dev/null` or `|| true` needed because `[ -f ... ]` guarantees binary exists before eval runs

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 06-01 closes the two gaps identified in the v1.0 milestone audit:
- Intel Mac users provisioned from this repo will now get brew in PATH correctly
- REQUIREMENTS.md accurately represents the v1.0 milestone state

Phase 6 is complete. No blockers or concerns.

---
*Phase: 06-gap-corrections*
*Completed: 2026-03-09*
