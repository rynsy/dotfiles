---
phase: 02-zmk-firmware
plan: 02
subsystem: firmware
tags: [zmk, keymap, github-actions, ci, submodule, git]

# Dependency graph
requires:
  - phase: 02-zmk-firmware/02-01
    provides: "Committed keymap edits in zmk submodule (media keys, Android layer)"
provides:
  - "ZMK keymap changes pushed to origin V3.0 (triggering GitHub Actions firmware build)"
  - "Parent dotfiles repo submodule pointer updated to new zmk commit 2893a52"
  - "GitHub Actions build triggered — user must verify green status"
affects: [flash-phase, 03-termux-android]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Submodule commits made while HEAD detached must be cherry-picked onto the branch before pushing"
    - "zmk submodule push: git checkout V3.0 → cherry-pick detached commits → git push origin V3.0"

key-files:
  created: []
  modified:
    - zmk/ (submodule pointer — parent dotfiles repo now at 2893a52)

key-decisions:
  - "Detached HEAD commits from plan 02-01 (ff8ba8d, 2893a52) required cherry-pick onto V3.0 before push — git checkout V3.0 alone left them behind"
  - "GitHub Actions build verification deferred to user (YOLO mode) — cannot be automated"

patterns-established:
  - "ZMK submodule workflow: edit in zmk/ → commit within submodule → checkout branch → cherry-pick if detached → push → update parent pointer"

requirements-completed: [ZMK-05]

# Metrics
duration: 5min
completed: 2026-03-08
---

# Phase 2 Plan 02: ZMK Push and Build Summary

**ZMK keymap commits cherry-picked onto V3.0 branch and pushed to origin, triggering GitHub Actions firmware build — parent dotfiles submodule pointer updated; user must verify green CI status**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-03-08T08:00:00Z
- **Completed:** 2026-03-08T08:05:00Z
- **Tasks:** 1 completed, 1 deferred (human verification — YOLO pre-approved)
- **Files modified:** 1 (zmk submodule pointer in parent repo)

## Accomplishments

- Cherry-picked 2 detached HEAD commits (from plan 02-01) onto V3.0 branch in zmk submodule
- Pushed V3.0 branch to `origin` (`ef92613..2893a52`) — GitHub Actions build triggered
- Updated parent dotfiles repo submodule pointer to commit `2893a52` (branch head)
- GitHub Actions build verification deferred to user per YOLO pre-approval

## Task Commits

1. **Task 1: Push zmk submodule to origin V3.0 and update parent pointer**
   - zmk submodule: cherry-pick commits `ff8ba8d` and `2893a52` onto V3.0
   - zmk push: `ef92613..2893a52  V3.0 -> V3.0` (push to origin succeeded)
   - Parent dotfiles: `03a2701` — "Update ZMK submodule: add media keys and Android BT layer"

2. **Task 2: Verify GitHub Actions build** — deferred (YOLO pre-approved; user verifies manually)

## Files Created/Modified

- `zmk/` (parent repo submodule pointer) — updated to `2893a52` (V3.0 branch tip) in commit `03a2701`

## Decisions Made

- **Cherry-pick required for detached commits:** The 2 commits made in plan 02-01 while HEAD was detached were not on V3.0 after `git checkout V3.0`. Cherry-pick was required to bring them onto the branch before pushing. This is the correct git submodule workflow when commits accumulate in detached HEAD state.
- **GitHub Actions verification deferred:** Build verification requires visiting https://github.com/rynsy/Adv360-Pro-ZMK/actions — cannot be automated. User pre-approved this deferral in YOLO mode.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Detached HEAD commits required cherry-pick before push**
- **Found during:** Task 1 (submodule git workflow)
- **Issue:** Plan assumed `git checkout V3.0` would keep the 2 plan 02-01 commits on V3.0, but they were made while HEAD was detached and were left behind when checking out V3.0 (`warning: you are leaving 2 commits behind`)
- **Fix:** Used `git cherry-pick 0060441 1af1fcf` to bring both commits onto V3.0 before pushing. New cherry-pick hashes: `ff8ba8d` and `2893a52`
- **Files modified:** zmk/config/adv360.keymap (unchanged content, new commit objects on V3.0)
- **Verification:** `git branch --show-current` → V3.0; `git log --oneline -3` shows both commits; `git push origin V3.0` succeeded
- **Committed in:** cherry-pick produced `ff8ba8d`, `2893a52` on V3.0; parent update `03a2701`

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug: detached HEAD handling)
**Impact on plan:** Required deviation — without cherry-pick the push would have sent only the upstream ef92613 with no keymap changes, defeating the entire plan.

## Issues Encountered

- **Submodule detached HEAD after plan 02-01:** Plan 02-01 committed directly while HEAD was detached at `ef92613` (the V3.0 tip at time of checkout). When plan 02-02 ran `git checkout V3.0`, git warned those commits were left behind. Cherry-pick resolved this cleanly with no conflicts.

## User Setup Required

**GitHub Actions verification is your next manual step:**

1. Visit https://github.com/rynsy/Adv360-Pro-ZMK/actions
2. Find the most recent run triggered by the push to V3.0 (should show ~minutes ago)
3. Wait for both jobs to complete:
   - `build (adv360_left)` — must be green
   - `build (adv360_right)` — must be green
4. Build typically takes 3–6 minutes
5. If green: download `firmware-no-clique` artifact, proceed to flash
6. If red: click the failing job, look for `binding count mismatch`, `undefined behavior`, or DTS syntax errors — report the error message

## Next Phase Readiness

- Push is complete and GitHub Actions should be running
- Once CI is confirmed green: download left.uf2 and right.uf2 from the firmware artifact
- Flash left half: Mod+Hotkey1 → USB → drag left.uf2
- Flash right half: Mod+Hotkey3 → USB → drag right.uf2
- Phase 02-zmk-firmware is otherwise complete

---
*Phase: 02-zmk-firmware*
*Completed: 2026-03-08*

## Self-Check: PASSED

- 02-02-SUMMARY.md: FOUND
- Parent submodule update commit 03a2701: FOUND
- zmk V3.0 cherry-pick commit 2893a52: FOUND
- origin/V3.0 at 2893a52 (push confirmed): FOUND
