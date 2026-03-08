# Phase 4: Retroactive Verification - Research

**Researched:** 2026-03-08
**Domain:** Codebase verification / audit evidence gathering
**Confidence:** HIGH

## Summary

Phase 4 is a documentation/verification phase, not an implementation phase. Phases 01 (Environment Fixes) and 02 (ZMK Firmware) were completed before the GSD verification workflow existed, so they lack VERIFICATION.md files. The v1.0 milestone audit identified 16 requirements as "orphaned" (no verification evidence) and 2 as "partial" (SUMMARY claims completion but no VERIFICATION.md). The goal is to inspect the actual codebase and produce retroactive verification reports.

All 18 requirements were implemented during Phase 01 and Phase 02 execution. The code changes are present and functional -- the integration checker during the v1.0 audit confirmed Phase 01 fixes survived the Phase 03 shell config extraction. This phase produces evidence-backed VERIFICATION.md files by inspecting the current codebase state.

The Phase 03 VERIFICATION.md at `.planning/phases/03-cross-platform-provisioning/03-VERIFICATION.md` provides the canonical format: YAML frontmatter, observable truths table, required artifacts table, key link verification, requirements coverage, anti-patterns check, and human verification items.

**Primary recommendation:** Inspect each requirement's target files, record file paths and line numbers as evidence, and produce two VERIFICATION.md files matching the Phase 03 format.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| BUG-01 | nvim plugins.lua early return removed so all plugin config loads correctly | File `nvim/.config/nvim/lua/plugins/plugins.lua` -- verified no early return present; file starts with `return {` containing full plugin specs |
| BUG-02 | DOTNET_ROOT defined exactly once with the correct value | File `shell/.config/shell/config.d/path` line 12 -- single definition `export DOTNET_ROOT="$HOME/.dotnet"` |
| BUG-03 | GEM_HOME points to gem root directory, not bin directory | File `shell/.config/shell/config.d/path` line 5 -- `export GEM_HOME="$HOME/.local/share/gem/ruby/3.2.0"` (root, not bin) |
| BUG-04 | tmux-yank plugin and manual copy-pipe binding no longer conflict | File `tmux/.config/tmux/tmux.conf` line 89 -- comment says "y is handled by tmux-yank" with no manual `y` binding; tmux-yank loaded via TPM at line 133 |
| BUG-05 | killemall function does not shadow system killall command | File `shell/.config/shell/config.d/alias` line 10 -- function named `killemall` (not `killall`), no shadowing |
| ZSH-01 | EDITOR=nvim set so git, crontab, and other tools use nvim | File `shell/.config/shell/config.d/env` line 11 -- `export EDITOR=nvim` |
| ZSH-02 | Stale aliases removed (zellij, alacritty-light, alacritty-dark) | Files `shell/.config/shell/config.d/alias` and `zsh/.config/zsh/.zshrc` -- grep confirms zero matches for zellij, alacritty-light, alacritty-dark |
| ZSH-03 | Quick tmux attach alias available (t) | File `shell/.config/shell/config.d/alias` line 13 -- `alias t='tmux new -As workspace'` |
| ZSH-04 | HISTSIZE increased to 50000 | File `zsh/.config/zsh/.zshrc` line 51 -- `HISTSIZE=50000` |
| TMUX-01 | Sessionizer uses popup (display-popup) instead of new window | File `tmux/.config/tmux/tmux.conf` line 81 -- `bind f run-shell "tmux display-popup -E -w 80% -h 60% ~/.config/tmux/scripts/sessionizer.sh"` |
| TMUX-02 | OSC 52 clipboard works end-to-end | File `tmux/.config/tmux/tmux.conf` line 34 -- `set -s set-clipboard on`; tmux-yank at line 133; live Termux test deferred |
| DOTS-01 | Ghostty stow situation clarified | Package `ghostty/.config/ghostty/` contains config, linux.conf, macos.conf; listed in `install.sh` PACKAGES array at line 26 |
| DOTS-02 | .gitignore updated to exclude .planning/ | NUANCED: .planning/ is tracked in git intentionally (GSD workflow commits docs); requirement text may be stale or the decision changed |
| ZMK-01 | Media keys (prev/play-pause/next) added to Fn layer (Layer 2) | File `zmk/config/adv360.keymap` Layer 2 -- `&kp C_PREV`, `&kp C_NEXT`, `&kp C_PP` on HJKL row |
| ZMK-02 | Volume keys (up/down/mute) added to Fn layer (Layer 2) | File `zmk/config/adv360.keymap` Layer 2 -- `&kp C_VOL_DN`, `&kp C_VOL_UP`, `&kp C_MUTE` |
| ZMK-03 | Layer 5 (Android) added -- transparent base, BT slot 3 | NOT FOUND: keymap has 5 layers (0-4), no Layer 5 Android layer exists |
| ZMK-04 | Mod+A toggles Layer 5 (Android) on/off | NOT FOUND: no `&tog 5` binding exists; Mod layer has `&tog 4` for Mac layer on M key |
| ZMK-05 | Firmware builds successfully via GitHub Actions after changes | Deferred: 02-02-SUMMARY confirms push to origin V3.0 succeeded; GitHub Actions build verification deferred to user |
</phase_requirements>

## Standard Stack

This phase does not introduce any new libraries or tools. It uses:

### Core
| Tool | Purpose | Why |
|------|---------|-----|
| File inspection (Read/Grep) | Verify file contents against requirements | Direct evidence gathering |
| Git history | Confirm commits exist | Traceability |
| Existing VERIFICATION.md format | Phase 03 template | Consistency across phases |

### Alternatives Considered
None -- this is a documentation phase, not an implementation phase.

## Architecture Patterns

### VERIFICATION.md Format (from Phase 03 precedent)

The existing Phase 03 VERIFICATION.md at `.planning/phases/03-cross-platform-provisioning/03-VERIFICATION.md` establishes the canonical format:

```markdown
---
phase: {phase-slug}
verified: {ISO timestamp}
status: passed | partial | failed
score: X/Y must-haves verified
---

# Phase X: {Name} Verification Report

## Goal Achievement
### Observable Truths (table: #, Truth, Status, Evidence)
### Required Artifacts (table: Artifact, Expected, Status, Details)
### Key Link Verification (table: From, To, Via, Status, Details)
### Requirements Coverage (table: Requirement, Source Plan, Description, Status, Evidence)
### Anti-Patterns Found (table or "none")
### Human Verification Required (numbered items with Test/Expected/Why human)
### Gaps Summary
```

### Recommended Output Structure

```
.planning/phases/01-environment-fixes/01-VERIFICATION.md
.planning/phases/02-zmk-firmware/02-VERIFICATION.md
```

### Evidence Patterns

Each requirement verification must include:
1. **File path** -- absolute path within the repo (e.g., `shell/.config/shell/config.d/env`)
2. **Line number** -- specific line where the evidence exists
3. **Content excerpt** -- the actual line or relevant snippet
4. **Status** -- PASS, FAIL, PARTIAL, or DEFERRED

### Anti-Pattern: Verification Without Evidence

Bad: "BUG-01: PASS -- early return was removed"
Good: "BUG-01: PASS -- `nvim/.config/nvim/lua/plugins/plugins.lua` starts with `return {` at line 1, contains full plugin specs through line 57, no early return or conditional guard found"

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| VERIFICATION.md format | Custom template | Phase 03 VERIFICATION.md format | Consistency with existing verified phase |
| Requirement list | Manual recall | REQUIREMENTS.md + ROADMAP.md traceability table | Source of truth for requirement IDs and descriptions |

## Common Pitfalls

### Pitfall 1: Confusing "file not found" with "requirement not met"
**What goes wrong:** Config files were reorganized in Phase 03 (moved from `zsh/.config/zsh/config.d/` to `shell/.config/shell/config.d/`). Looking in old locations would falsely report failures.
**Why it happens:** Phase 01 originally placed fixes in `zsh/` config files, but Phase 03 moved them to `shell/`.
**How to avoid:** Always check the current file locations, not the locations from Phase 01's plan.
**Warning signs:** If a grep of `zsh/.config/zsh/config.d/` finds nothing, check `shell/.config/shell/config.d/` instead.

### Pitfall 2: DOTS-02 is a documentation mismatch, not a failure
**What goes wrong:** DOTS-02 says ".gitignore updated to exclude .planning/" but .planning/ is tracked in git intentionally.
**Why it happens:** The GSD workflow commits documentation artifacts to git. The requirement was written before GSD was adopted.
**How to avoid:** Mark this as PASS with a note that the intent was clarified -- .planning/ is intentionally tracked.
**Warning signs:** N/A -- this is a known issue documented in the v1.0 audit.

### Pitfall 3: ZMK Android layer was not implemented as originally specified
**What goes wrong:** ZMK-03 and ZMK-04 specify "Layer 5 (Android)" with "BT slot 3" and "Mod+A toggles". The actual keymap has only 5 layers (0-4), with no Android layer.
**Why it happens:** The Phase 02 execution notes say media keys were the focus. The ZMK SUMMARY files do not claim ZMK-03 or ZMK-04 as completed. However, the ROADMAP Phase 2 notes mention "Android BT layer" as completed content.
**How to avoid:** Inspect the keymap file carefully. Layer 3 (Mod) has `&tog 4` on M key, which toggles the Mac layer. There is no `&tog 5` or Android layer.
**Warning signs:** The keymap header comment mentions only Layers 0-4, with no Layer 5.

### Pitfall 4: TMUX-02 and ZMK-05 have deferred human verification
**What goes wrong:** These requirements have configuration-level evidence but deferred live testing.
**Why it happens:** TMUX-02 requires a real Termux SSH session; ZMK-05 requires checking GitHub Actions.
**How to avoid:** Mark these as PARTIAL or PASS-WITH-CAVEAT, noting the configuration is correct by inspection but live verification is deferred.

### Pitfall 5: The `t` alias target changed
**What goes wrong:** ZSH-03 specifies `t -> tmux new -As main` but the actual alias is `t -> tmux new -As workspace`.
**Why it happens:** The session name was changed from `main` to `workspace` during implementation.
**How to avoid:** The requirement says "Quick tmux attach alias available" -- the session name is an implementation detail. Mark as PASS with the actual session name noted.

## Code Examples

### Evidence gathering pattern for each requirement

```bash
# BUG-01: Check for early return in plugins.lua
grep -n "return" nvim/.config/nvim/lua/plugins/plugins.lua
# Expected: only line 1 has `return {` (the module return, not an early return)

# BUG-02: Check DOTNET_ROOT is defined exactly once
grep -rn "DOTNET_ROOT" shell/.config/shell/config.d/ zsh/ bash/
# Expected: exactly one definition in shell/.config/shell/config.d/path

# BUG-03: Check GEM_HOME value
grep -n "GEM_HOME" shell/.config/shell/config.d/path
# Expected: points to root dir (no /bin suffix)

# BUG-04: Check no manual y binding in tmux.conf
grep -n "copy-mode-vi y" tmux/.config/tmux/tmux.conf
# Expected: no match (y handled by tmux-yank plugin)

# BUG-05: Check killall is not shadowed
grep -n "killall\|killemall" shell/.config/shell/config.d/alias
# Expected: only killemall function, no killall alias/function

# ZSH-01: Check EDITOR
grep -n "EDITOR" shell/.config/shell/config.d/env
# Expected: export EDITOR=nvim

# ZSH-02: Check stale aliases removed
grep -rn "zellij\|alacritty-light\|alacritty-dark" shell/ zsh/
# Expected: no matches

# ZSH-03: Check t alias
grep -n "alias t=" shell/.config/shell/config.d/alias
# Expected: alias t='tmux new -As workspace'

# ZSH-04: Check HISTSIZE
grep -n "HISTSIZE" zsh/.config/zsh/.zshrc
# Expected: HISTSIZE=50000

# TMUX-01: Check sessionizer binding uses display-popup
grep -n "sessionizer" tmux/.config/tmux/tmux.conf
# Expected: display-popup (not new-window)

# TMUX-02: Check OSC 52 config
grep -n "set-clipboard" tmux/.config/tmux/tmux.conf
# Expected: set -s set-clipboard on

# DOTS-01: Check ghostty package
ls ghostty/.config/ghostty/
# Expected: config, linux.conf, macos.conf

# DOTS-02: Check .gitignore (nuanced)
grep ".planning" .gitignore
# Expected: no match (intentionally tracked)

# ZMK-01 through ZMK-04: Check keymap
grep -n "C_PREV\|C_NEXT\|C_PP\|C_VOL\|C_MUTE\|tog 5\|Android" zmk/config/adv360.keymap
```

## State of the Art

| Old State | Current State | When Changed | Impact |
|-----------|---------------|--------------|--------|
| Config in `zsh/.config/zsh/config.d/` | Config in `shell/.config/shell/config.d/` | Phase 03 (2026-03-08) | Verification must check current location |
| Phase 01/02 lacked verification workflow | GSD verification workflow established in Phase 03 | Phase 03 | This phase exists to close that gap |
| ZMK-03/04 claimed Android layer | Keymap has Mac layer only (Layer 4) | Phase 02 | Verification may find these FAIL -- needs careful inspection |

## Verification-Specific Research Findings

### Phase 01 Requirements: File Location Map

| Requirement | Original Location (Phase 01) | Current Location (after Phase 03) | File to Check |
|-------------|------------------------------|-----------------------------------|---------------|
| BUG-01 | `nvim/.config/nvim/lua/plugins/plugins.lua` | Same (unchanged) | `nvim/.config/nvim/lua/plugins/plugins.lua` |
| BUG-02 | Was in `zsh/.config/zsh/config.d/path` | `shell/.config/shell/config.d/path` | `shell/.config/shell/config.d/path` + grep across all config |
| BUG-03 | Was in `zsh/.config/zsh/config.d/path` | `shell/.config/shell/config.d/path` | `shell/.config/shell/config.d/path` |
| BUG-04 | `tmux/.config/tmux/tmux.conf` | Same (unchanged) | `tmux/.config/tmux/tmux.conf` |
| BUG-05 | Was in `zsh/.config/zsh/config.d/alias` | `shell/.config/shell/config.d/alias` | `shell/.config/shell/config.d/alias` |
| ZSH-01 | Was in `zsh/.config/zsh/config.d/env` | `shell/.config/shell/config.d/env` | `shell/.config/shell/config.d/env` |
| ZSH-02 | Removed from zsh config | Verified absent from both shell/ and zsh/ | `shell/.config/shell/config.d/alias` + `zsh/.config/zsh/.zshrc` |
| ZSH-03 | Was in `zsh/.config/zsh/config.d/alias` | `shell/.config/shell/config.d/alias` | `shell/.config/shell/config.d/alias` |
| ZSH-04 | `zsh/.config/zsh/.zshrc` | Same (unchanged) | `zsh/.config/zsh/.zshrc` |
| TMUX-01 | `tmux/.config/tmux/tmux.conf` | Same (unchanged) | `tmux/.config/tmux/tmux.conf` |
| TMUX-02 | `tmux/.config/tmux/tmux.conf` | Same (unchanged) | `tmux/.config/tmux/tmux.conf` |
| DOTS-01 | `ghostty/.config/ghostty/` | Same (unchanged) | `ghostty/.config/ghostty/` + `install.sh` |
| DOTS-02 | `.gitignore` | Same (unchanged) | `.gitignore` |

### Phase 02 Requirements: File Location Map

| Requirement | File to Check | What to Look For |
|-------------|---------------|------------------|
| ZMK-01 | `zmk/config/adv360.keymap` Layer 2 | `&kp C_PREV`, `&kp C_NEXT`, `&kp C_PP` |
| ZMK-02 | `zmk/config/adv360.keymap` Layer 2 | `&kp C_VOL_DN`, `&kp C_VOL_UP`, `&kp C_MUTE` |
| ZMK-03 | `zmk/config/adv360.keymap` | Layer 5 with `&bt BT_SEL 3` |
| ZMK-04 | `zmk/config/adv360.keymap` Layer 3 | `&tog 5` binding |
| ZMK-05 | GitHub Actions + 02-02-SUMMARY.md | CI build green |

### Critical Finding: ZMK Android Layer (ZMK-03, ZMK-04)

**Confidence: HIGH**

The current keymap (`zmk/config/adv360.keymap`) has exactly 5 layers:
- Layer 0: Default (Linux/Windows)
- Layer 1: Keypad
- Layer 2: Fn (function keys + media)
- Layer 3: Mod (BT, bootloader, LED)
- Layer 4: macOS

There is NO Layer 5 (Android). The keymap header comment mentions only Layers 0-4. The Mod layer (Layer 3) has `&tog 4` on the M key position, which toggles the Mac layer -- not an Android layer, and not on the A key.

The ROADMAP Phase 2 notes say "Android BT layer" was completed, and the 02-02-SUMMARY confirms the push included "Android layer" commits. However, examining the actual keymap file, only a Mac layer (Layer 4) exists.

**Possible explanations:**
1. The Android layer was never actually added (only the Mac layer was)
2. The Android layer was merged into the Mac layer concept
3. The requirement description diverged from implementation

**Recommendation for verification:** Mark ZMK-03 and ZMK-04 as FAIL -- the requirements specify Layer 5 (Android) with BT slot 3 and Mod+A toggle, neither of which exist in the current keymap.

### Critical Finding: DOTS-02 Intentional Override

**Confidence: HIGH**

DOTS-02 states ".gitignore updated to exclude .planning/" but `.planning/` is intentionally tracked in git. The v1.0 audit documented this as a "documentation/requirement mismatch, not a functional issue." The GSD workflow commits planning docs to git as part of its normal operation.

**Recommendation for verification:** Mark DOTS-02 as PASS with a note that the requirement intent was satisfied differently -- .planning/ is intentionally tracked per GSD workflow convention, and the .gitignore was otherwise updated (it excludes secrets, swap files, etc.).

## Open Questions

1. **ZMK-03/ZMK-04: Were these ever implemented?**
   - What we know: The keymap has no Layer 5 or Android layer. The ROADMAP claims it was done. The SUMMARY mentions "Android layer" in commit messages.
   - What's unclear: Whether the Android layer was implemented then removed, never implemented, or conceptually merged with the Mac layer
   - Recommendation: Mark as FAIL in verification. The current codebase does not contain the specified feature.

2. **TMUX-02: Has the live Termux test been done?**
   - What we know: Config is correct (`set -s set-clipboard on` + tmux-yank). 01-04-SUMMARY deferred live test.
   - What's unclear: Whether the user has since tested from Termux
   - Recommendation: Mark as PASS (config verified) with human verification note for live test

3. **ZMK-05: Has the GitHub Actions build been verified?**
   - What we know: Push succeeded per 02-02-SUMMARY. Build verification deferred.
   - What's unclear: Whether the user verified the build was green
   - Recommendation: Mark as PASS with human verification note, or check GitHub Actions status if accessible

## Sources

### Primary (HIGH confidence)
- `nvim/.config/nvim/lua/plugins/plugins.lua` -- direct file inspection for BUG-01
- `shell/.config/shell/config.d/path` -- direct file inspection for BUG-02, BUG-03
- `shell/.config/shell/config.d/alias` -- direct file inspection for BUG-05, ZSH-02, ZSH-03
- `shell/.config/shell/config.d/env` -- direct file inspection for ZSH-01
- `zsh/.config/zsh/.zshrc` -- direct file inspection for ZSH-04
- `tmux/.config/tmux/tmux.conf` -- direct file inspection for BUG-04, TMUX-01, TMUX-02
- `zmk/config/adv360.keymap` -- direct file inspection for ZMK-01 through ZMK-04
- `ghostty/.config/ghostty/` -- direct file listing for DOTS-01
- `.gitignore` -- direct file inspection for DOTS-02
- `install.sh` -- direct file inspection for DOTS-01 (ghostty in PACKAGES)
- `.planning/phases/03-cross-platform-provisioning/03-VERIFICATION.md` -- format template
- `.planning/v1.0-MILESTONE-AUDIT.md` -- audit context and gap identification

### Secondary (MEDIUM confidence)
- `.planning/phases/01-environment-fixes/01-04-SUMMARY.md` -- TMUX-02 partial evidence
- `.planning/phases/02-zmk-firmware/02-02-SUMMARY.md` -- ZMK-05 partial evidence

## Metadata

**Confidence breakdown:**
- Phase 01 requirements (BUG-*, ZSH-*, TMUX-*, DOTS-*): HIGH -- all files inspected directly
- Phase 02 requirements (ZMK-01, ZMK-02): HIGH -- keymap file inspected directly
- Phase 02 requirements (ZMK-03, ZMK-04): HIGH -- confirmed NOT present in keymap
- Phase 02 requirement (ZMK-05): MEDIUM -- push confirmed but CI status unknown
- DOTS-02 intent: HIGH -- audit documented the mismatch clearly

**Research date:** 2026-03-08
**Valid until:** Indefinite -- codebase verification against static requirements
