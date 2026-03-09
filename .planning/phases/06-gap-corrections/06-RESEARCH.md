# Phase 6: Gap Corrections + Intel macOS PATH Fix - Research

**Researched:** 2026-03-09
**Domain:** Dotfiles documentation correction + shell PATH configuration
**Confidence:** HIGH

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ZMK-03 | Layer 5 (Android) added — descoped from v1 to v2 | Confirmed FAIL in 02-VERIFICATION.md; REQUIREMENTS.md checkbox inaccurate; correct by unchecking and moving to v2 section |
| ZMK-04 | Mod+A toggles Layer 5 — descoped from v1 to v2 | Confirmed FAIL in 02-VERIFICATION.md; depends on ZMK-03; correct by unchecking and moving to v2 section |
| PROV-02 | install.sh supports macOS via Homebrew | Marked complete but Intel Mac PATH gap found in audit; fix by adding `/usr/local` fallback to `path.darwin` |
</phase_requirements>

---

## Summary

Phase 6 closes two types of gaps surfaced in the v1.0 milestone audit: documentation inaccuracies (REQUIREMENTS.md checkboxes that claim completion for unimplemented work) and a functional flow defect (Intel Mac users do not have `brew` in PATH after provisioning).

The documentation fix is straightforward: ZMK-03 and ZMK-04 have `[x]` checkboxes in REQUIREMENTS.md but are confirmed FAIL in `02-VERIFICATION.md`. The Android BT layer was lost during a merge conflict in Phase 02. The correct action is to uncheck these two requirements in the v1 section, move them to the v2 section, and update the traceability table. ZMK-06 already exists in v2 to absorb continued Android layer work.

The PATH fix is equally contained: `shell/.config/shell/config.d/path.darwin` currently contains only `eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || true`, which only works on Apple Silicon Macs (where Homebrew lives at `/opt/homebrew`). On Intel Macs, Homebrew is installed at `/usr/local` and the `shellenv` eval fails silently (the `|| true` suppresses the error). The fix is a second conditional eval for `/usr/local/bin/brew` that runs only when the Apple Silicon path is absent.

**Primary recommendation:** Two targeted edits — one to REQUIREMENTS.md (checkbox + traceability corrections), one to `path.darwin` (Intel Mac fallback) — with no other files touched.

---

## Standard Stack

### Core (no new libraries needed)

This phase touches only existing shell scripts and markdown files. No new packages, tools, or dependencies are required.

| File | Current State | Change |
|------|--------------|--------|
| `.planning/REQUIREMENTS.md` | ZMK-03/04 marked `[x]` in v1 section; traceability shows "Deferred" | Uncheck boxes, move entries to v2, update traceability |
| `shell/.config/shell/config.d/path.darwin` | Single `eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" \|\| true` | Add Intel Mac fallback eval |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Inline Intel fallback in `path.darwin` | Detect in `install.sh` then write PATH to a file | More complex; the shell config file is the right place for shell PATH logic |
| Separate `path.darwin.intel` file | Single `path.darwin` with both evals | Single file is simpler; both evals are short and self-explanatory |

---

## Architecture Patterns

### Intel vs Apple Silicon Homebrew Paths

Homebrew installs to different prefixes depending on CPU architecture:

- **Apple Silicon:** `/opt/homebrew` — this is the new standard since macOS Big Sur (2020)
- **Intel:** `/usr/local` — the traditional path, still used on Intel Macs

The `brew shellenv` command outputs the correct `export PATH`, `HOMEBREW_PREFIX`, `HOMEBREW_CELLAR`, and `HOMEBREW_REPOSITORY` for whichever prefix it is run from. Evaluating it with `eval` is the canonical Homebrew-recommended approach.

The correct multi-architecture pattern:

```bash
# macOS-specific paths (Homebrew)
# Apple Silicon first, Intel fallback
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
```

This pattern:
- Tries Apple Silicon path first (matches current behavior for existing users)
- Falls back to Intel path if Apple Silicon path is absent
- Uses `if/elif` instead of `|| true` — the `|| true` was suppressing the error on Intel which is exactly the bug
- Does not require `2>/dev/null` when guarded by `[ -f ... ]` (the binary exists before eval is called)

**Confidence:** HIGH — matches official Homebrew documentation guidance and the same pattern used in `install.sh` lines 58-62 (which already handles both paths correctly during installation).

### The Existing install.sh Already Does This Correctly

Lines 58-62 of `install.sh` already implement the correct dual-path pattern:

```bash
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
```

`path.darwin` should mirror this same logic so that shell sessions after provisioning have the same PATH that the install script used during setup. The fix is essentially copying this working pattern from `install.sh` into `path.darwin`.

### REQUIREMENTS.md Edit Pattern

The REQUIREMENTS.md file uses GitHub Flavored Markdown task lists. The edit requires:

1. **In the `### ZMK` section under `## v1 Requirements`**: Change `[x]` to `[ ]` for ZMK-03 and ZMK-04
2. **In the `### ZMK` section under `## v2 Requirements`**: ZMK-03 and ZMK-04 entries already exist there (confirmed in current file) with the correct descriptions and "(descoped from v1; ...)" notes — no addition needed, they are already present
3. **In the `## Traceability` table**: ZMK-03 and ZMK-04 rows already show "Phase 6 (descoped to v2)" and "Deferred" — the table is already correct
4. **In the `## Coverage` summary**: Update the v1 count note from "16 total — all complete (ZMK-03/ZMK-04 descoped to v2)" to accurately reflect 14 complete + 2 deferred

Current state of REQUIREMENTS.md (confirmed by reading the file):
- Line 31: `- [x] **ZMK-03**: Layer 5 (Android)...` — needs to become `- [ ]`
- Line 32: `- [x] **ZMK-04**: Mod+A toggles...` — needs to become `- [ ]`
- Lines 126-127: Traceability already correct (shows Phase 6, Deferred)
- Line 144: Coverage note already says "(ZMK-03/ZMK-04 descoped to v2)" — verify wording matches unchecked state

Wait — re-reading REQUIREMENTS.md lines 31-32:

```
- [x] **ZMK-01**: Media keys (prev/play-pause/next) added to Fn layer (Layer 2)
- [x] **ZMK-02**: Volume keys (up/down/mute) added to Fn layer (Layer 2)
- [x] **ZMK-05**: Firmware builds successfully via GitHub Actions after changes
```

And v2 section (lines 58-59):
```
- **ZMK-03**: Layer 5 (Android) added...
- **ZMK-04**: Mod+A toggles Layer 5...
```

ZMK-03 and ZMK-04 are **already in the v2 section without checkboxes**. They are NOT in the v1 section at all — they were already moved. The v1 ZMK section only shows ZMK-01, ZMK-02, ZMK-05 with `[x]`.

This means the documentation correction needed is narrower: the traceability table and coverage summary may already be correct. The main remaining task is verifying the current state precisely and confirming that REQUIREMENTS.md already accurately shows ZMK-03/04 as deferred to v2 (no `[x]` checkboxes for them in v1).

**Revised assessment:** REQUIREMENTS.md may already be partially or fully correct. The planner must read the file and verify before making changes. If ZMK-03/04 are already properly unchecked and in v2, the documentation task reduces to verifying the traceability table and coverage summary are accurate.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead |
|---------|-------------|-------------|
| Detecting Intel vs Apple Silicon | Custom `uname -m` check | `[ -f /opt/homebrew/bin/brew ]` guard — simpler, directly tests what matters |
| Sourcing brew env | Manually exporting HOMEBREW_* vars | `eval "$(brew shellenv)"` — canonical Homebrew approach, handles all env vars |

---

## Common Pitfalls

### Pitfall 1: Silent Failure Masking the Bug

**What goes wrong:** The original `eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)" || true` silently swallows the error when `/opt/homebrew/bin/brew` does not exist. The user sees no error but `brew` is not in PATH.

**Why it happens:** `2>/dev/null` hides stderr from the failed brew binary lookup; `|| true` prevents the exit code from failing the shell startup. The intent was fault-tolerance but it became fault-hiding.

**How to avoid:** Guard with `[ -f ... ]` before evaluating. Only run `eval` when the binary actually exists.

### Pitfall 2: Assuming REQUIREMENTS.md State Without Reading

**What goes wrong:** The audit report says ZMK-03/04 are "[x] (inaccurate)" in REQUIREMENTS.md. But the current REQUIREMENTS.md (read directly) shows ZMK-03/04 only in the v2 section without checkboxes. There is a discrepancy between the audit's description and the actual current file state.

**Why it happens:** The audit may have been written before the file was partially corrected, or may have been describing the v1 section incorrectly. The actual file is the source of truth.

**How to avoid:** The planner must read REQUIREMENTS.md directly and compare against the audit claims before making changes. Only change what is actually wrong.

### Pitfall 3: Touching More Than Needed

**What goes wrong:** Phase 6 is a correction phase. Scope creep (fixing the stale `install.sh` conflict check, fixing the ghostty Linux stow issue, etc.) risks introducing new bugs and delays.

**How to avoid:** Phase 6 success criteria are explicit: (1) ZMK-03/04 documentation corrected, (2) traceability table reflects deferred status, (3) `path.darwin` Intel fallback added. Do only these three things.

### Pitfall 4: Breaking Existing Apple Silicon Users

**What goes wrong:** Modifying `path.darwin` incorrectly could break Apple Silicon Macs that currently work.

**How to avoid:** The `if/elif` pattern tries Apple Silicon first. Apple Silicon users hit the first branch and get identical behavior to today. Only the `elif` branch is new.

---

## Code Examples

### Corrected path.darwin

```bash
# macOS-specific paths (Homebrew)
# Apple Silicon (/opt/homebrew) first; Intel Mac fallback (/usr/local)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
```

Source: mirrors pattern at `install.sh` lines 58-62 (already in this repository).

### Verification Command (manual, on Intel Mac)

```bash
# After stowing shell/ on Intel Mac:
source ~/.config/shell/config.d/path.darwin
which brew   # should resolve to /usr/local/bin/brew
brew --version  # should succeed
```

---

## State of the Art

| Old Approach | Current Approach | When Changed |
|--------------|------------------|--------------|
| `|| true` to suppress brew eval errors | `[ -f ... ]` guard before eval | This phase |
| ZMK-03/04 marked `[x]` in v1 (inaccurate) | Properly deferred to v2 | This phase |

---

## Open Questions

1. **Exact current state of ZMK-03/04 checkboxes in REQUIREMENTS.md**
   - What we know: Audit says they are `[x]` (inaccurate); direct file read shows they are only in v2 section without checkboxes
   - What's unclear: Did a partial correction already happen between audit time and now?
   - Recommendation: Planner reads REQUIREMENTS.md directly before editing. If ZMK-03/04 are already correctly unchecked and in v2, that task is done; focus on traceability table and coverage summary accuracy.

2. **Coverage summary line in REQUIREMENTS.md**
   - What we know: Line 144 says "v1 requirements: 16 total — all complete (ZMK-03/ZMK-04 descoped to v2)"
   - What's unclear: Should this read "14 complete" (excluding ZMK-03/04) for accuracy?
   - Recommendation: Update to "14 complete, 2 descoped to v2" to be precise.

---

## Validation Architecture

This phase has no automated tests — all changes are documentation edits and a one-line shell config fix. Validation is manual inspection.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual inspection only |
| Config file | none |
| Quick run command | `grep -n 'ZMK-03\|ZMK-04' .planning/REQUIREMENTS.md` |
| Full suite command | Read REQUIREMENTS.md + `cat shell/.config/shell/config.d/path.darwin` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ZMK-03 | Unchecked in v1, present in v2 without checkbox | manual | `grep -n 'ZMK-03' .planning/REQUIREMENTS.md` | ✅ |
| ZMK-04 | Unchecked in v1, present in v2 without checkbox | manual | `grep -n 'ZMK-04' .planning/REQUIREMENTS.md` | ✅ |
| PROV-02 | path.darwin has Intel fallback | manual | `cat shell/.config/shell/config.d/path.darwin` | ✅ |

### Wave 0 Gaps

None — existing files cover all phase requirements. No new test infrastructure needed.

---

## Sources

### Primary (HIGH confidence)

- Direct file reads: `shell/.config/shell/config.d/path.darwin`, `install.sh`, `.planning/REQUIREMENTS.md` — current repository state
- `.planning/v1.0-MILESTONE-AUDIT.md` — gap analysis with evidence

### Secondary (MEDIUM confidence)

- `install.sh` lines 58-62 — reference implementation of the correct dual-arch pattern (in this repository)

### Tertiary (LOW confidence)

None — all findings based on direct file inspection.

---

## Metadata

**Confidence breakdown:**
- REQUIREMENTS.md correction scope: HIGH — file read directly; exact lines identified
- path.darwin fix: HIGH — pattern verified against working implementation in install.sh
- No regressions for Apple Silicon: HIGH — if/elif preserves existing behavior

**Research date:** 2026-03-09
**Valid until:** 2026-04-09 (stable domain; no external dependencies)
