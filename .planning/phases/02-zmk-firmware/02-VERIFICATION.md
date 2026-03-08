---
phase: 02-zmk-firmware
verified: 2026-03-08T23:07:00Z
status: partial
score: 3/5 must-haves verified
---

# Phase 2: ZMK Firmware Verification Report

**Phase Goal:** The keyboard firmware has media/volume keys on the Fn layer and a working Android BT layer, built and flashed successfully
**Verified:** 2026-03-08T23:07:00Z
**Status:** partial
**Re-verification:** No -- initial retroactive verification (Phase 02 was executed before GSD verification workflow existed)

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Media keys (prev/play-pause/next) are on the Fn layer | VERIFIED | `zmk/config/adv360.keymap` line 102: `&kp C_PREV`, `&kp C_NEXT`, `&kp C_PP` on HJKL row and semicolon position |
| 2 | Volume keys (up/down/mute) are on the Fn layer | VERIFIED | `zmk/config/adv360.keymap` lines 102-103: `&kp C_VOL_DN`, `&kp C_VOL_UP` on JK positions; `&kp C_MUTE` on M position |
| 3 | Android BT layer exists as Layer 5 | FAILED | Keymap has exactly 5 layers (0-4). Header comment (lines 1-10) lists only Layers 0-4. No Layer 5, no "Android" reference in layer definitions. |
| 4 | Mod+A toggles Layer 5 (Android) | FAILED | No `&tog 5` binding exists anywhere in keymap. Layer 3 (Mod) line 118 has `&tog 4` on M key position (Mac layer toggle), not `&tog 5` on A key. |
| 5 | Firmware builds successfully via GitHub Actions | VERIFIED | `gh run list` shows most recent V3.0 build: `completed success` -- "feat: move media keys to right-hand HJKL cluster on Fn layer" (2026-03-08T21:04:28Z, 2m18s) |

**Score:** 3/5 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `zmk/config/adv360.keymap` | Keymap with media keys, volume keys, and Android layer | PARTIAL | Media and volume keys present on Layer 2 (Fn). Android layer (Layer 5) does not exist. Mac layer (Layer 4) exists instead. |
| Layer 2 (Fn) media bindings | `C_PREV`, `C_NEXT`, `C_PP` on HJKL row | VERIFIED | Line 102: H=C_PREV, L=C_NEXT, ;=C_PP (play/pause) |
| Layer 2 (Fn) volume bindings | `C_VOL_DN`, `C_VOL_UP`, `C_MUTE` | VERIFIED | Lines 102-103: J=C_VOL_DN, K=C_VOL_UP, M=C_MUTE |
| Layer 5 (Android) | Transparent base with `&bt BT_SEL 3` | MISSING | No Layer 5 exists in keymap. Only Layers 0-4 defined. |
| Layer 3 Mod+A toggle | `&tog 5` on A key in Mod layer | MISSING | Mod layer has `&tog 4` on M key (line 118), not `&tog 5` on A key |
| GitHub Actions green build | Successful CI build on V3.0 | VERIFIED | `gh run list --repo rynsy/Adv360-Pro-ZMK --limit 5` confirms latest build passed |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `zmk/config/adv360.keymap` | GitHub Actions firmware build | `git push origin V3.0` | WIRED | 02-02-SUMMARY confirms push `ef92613..2893a52 V3.0 -> V3.0`; `gh run list` shows completed success build |
| Layer 2 Fn bindings | OS media control | USB HID consumer codes | WIRED | `C_PREV`, `C_NEXT`, `C_PP`, `C_VOL_DN`, `C_VOL_UP`, `C_MUTE` are standard HID codes -- OS-agnostic per keymap comment (line 96) |
| Layer 3 Mod layer | Layer 4 Mac toggle | `&tog 4` on M key | WIRED | Line 118: `&tog 4` toggles Mac layer; header comment (line 9) documents "Mod+M = toggle Mac layer" |
| Parent dotfiles repo | zmk submodule | Submodule pointer | WIRED | Parent repo updated submodule pointer to `2893a52` in commit `03a2701` per 02-02-SUMMARY |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| ZMK-01 | 02-01 | Media keys (prev/play-pause/next) added to Fn layer (Layer 2) | PASS | `zmk/config/adv360.keymap` line 102: Layer 2 (Fn) row contains `&kp C_PREV` (H position), `&kp C_NEXT` (L position), `&kp C_PP` (semicolon position). Keymap header (line 6) documents: "Layer 2: Fn -- function keys + media (HJKL=prev/vol/next, ;=play, M=mute)". Summary comment (lines 153-155) confirms placement. |
| ZMK-02 | 02-01 | Volume keys (up/down/mute) added to Fn layer (Layer 2) | PASS | `zmk/config/adv360.keymap` lines 102-103: `&kp C_VOL_DN` (J position), `&kp C_VOL_UP` (K position) on line 102; `&kp C_MUTE` (M position) on line 103. All three volume controls present on Fn layer. |
| ZMK-03 | 02-01 | Layer 5 (Android) added -- transparent base, BT slot 3 | FAIL | Keymap has exactly 5 layers (0-4): Default, Keypad, Fn, Mod, macOS. Header comment (lines 4-9) lists only these 5 layers. No Layer 5 definition exists. No "Android" reference in any layer node. GitHub Actions history shows a commit "feat(02-01): add Android layer toggle and layer_android node" was pushed but was subsequently overwritten by "feat: move media keys to right-hand HJKL cluster on Fn layer" which appears to have resolved a merge conflict in favor of the HJKL layout without the Android layer. |
| ZMK-04 | 02-01 | Mod+A toggles Layer 5 (Android) on/off | FAIL | No `&tog 5` binding exists anywhere in `zmk/config/adv360.keymap`. Layer 3 (Mod) at line 118 has `&tog 4` on the M key position (toggling Mac layer, Layer 4). The A key position in Layer 3 (line 117) contains `&none`. There is no mechanism to toggle a non-existent Layer 5. |
| ZMK-05 | 02-02 | Firmware builds successfully via GitHub Actions after changes | PASS | `gh run list --repo rynsy/Adv360-Pro-ZMK --limit 5` output shows most recent V3.0 push build: status=`completed`, conclusion=`success`, title="feat: move media keys to right-hand HJKL cluster on Fn layer", completed 2026-03-08T21:04:28Z in 2m18s. Push confirmed by 02-02-SUMMARY: `ef92613..2893a52 V3.0 -> V3.0`. |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| ROADMAP.md | 52 | Phase 2 marked "Complete" but ZMK-03/ZMK-04 are unimplemented | Warning | ROADMAP claims "Android BT layer" as completed content, but keymap has no Android layer. Documentation-reality mismatch. |
| 02-02-SUMMARY.md | 67 | Commit message references "Android BT layer" | Info | Parent dotfiles commit `03a2701` message says "add media keys and Android BT layer" but the final keymap does not contain an Android layer. The Android layer was likely lost during a merge conflict resolution. |

### Human Verification Required

#### 1. Confirm Android Layer Decision

**Test:** User decides whether ZMK-03 and ZMK-04 should be (a) descoped entirely, (b) deferred to a future phase (v2 requirement ZMK-06 already exists for Android layer updates), or (c) re-implemented
**Expected:** Decision documented; ROADMAP and REQUIREMENTS updated accordingly
**Why human:** Architectural decision about whether the Android layer feature is still wanted

#### 2. Verify Firmware Flash and Media Keys Work

**Test:** Flash the firmware artifact from the latest successful GitHub Actions build and test media keys on the physical keyboard
**Expected:** Fn+H=previous track, Fn+J=volume down, Fn+K=volume up, Fn+L=next track, Fn+;=play/pause, Fn+M=mute
**Why human:** Requires physical keyboard hardware and firmware flashing

### Gaps Summary

#### Gap 1: ZMK-03 and ZMK-04 -- Android Layer Not Implemented

**Status:** FAIL -- requirements specify Layer 5 (Android) with transparent base and BT slot 3, plus Mod+A toggle. Neither exists in the current keymap.

**Evidence of what happened:** GitHub Actions history shows a build for "feat(02-01): add Android layer toggle and layer_android node" (2026-03-08T07:41:15Z) that succeeded, followed by a later build "feat: move media keys to right-hand HJKL cluster on Fn layer" (2026-03-08T21:04:28Z) that also succeeded. The second push appears to have been a merge conflict resolution (merging upstream changes with local edits) that dropped the Android layer in favor of the HJKL media key layout.

**Possible explanations:**
1. The Android layer was added in an earlier commit but lost during merge conflict resolution with upstream
2. The requirement scope diverged from implementation -- the Mac layer (Layer 4) was prioritized over the Android layer
3. The ROADMAP was updated to show completion before verifying the final merged keymap

**Recommendation:** These requirements are candidates for descoping or deferral. The v2 requirements in REQUIREMENTS.md already include ZMK-06 ("Android layer updated with any remaps discovered through actual use"), suggesting the Android layer was always intended as a future refinement. Consider marking ZMK-03 and ZMK-04 as "descoped" or "deferred to v2" rather than leaving them as failed v1 requirements.

#### Gap 2: ZMK-05 CI Build -- Verified via gh CLI

**Status:** PASS -- the latest GitHub Actions build for V3.0 completed successfully. This was previously marked as "deferred" in 02-02-SUMMARY but is now confirmed green via `gh run list`.

No additional gaps. Media keys (ZMK-01) and volume keys (ZMK-02) are fully implemented and verified in the codebase.

---

_Verified: 2026-03-08T23:07:00Z_
_Verifier: Claude (gsd-executor, retroactive verification)_
