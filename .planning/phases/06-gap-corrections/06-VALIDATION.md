---
phase: 6
slug: gap-corrections
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-09
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual inspection only |
| **Config file** | none |
| **Quick run command** | `grep -n 'ZMK-03\|ZMK-04' .planning/REQUIREMENTS.md` |
| **Full suite command** | `grep -n 'ZMK-03\|ZMK-04' .planning/REQUIREMENTS.md && cat shell/.config/shell/config.d/path.darwin` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `grep -n 'ZMK-03\|ZMK-04' .planning/REQUIREMENTS.md`
- **After every plan wave:** Run `grep -n 'ZMK-03\|ZMK-04' .planning/REQUIREMENTS.md && cat shell/.config/shell/config.d/path.darwin`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 6-01-01 | 01 | 1 | ZMK-03 | manual | `grep -n 'ZMK-03' .planning/REQUIREMENTS.md` | ✅ | ⬜ pending |
| 6-01-02 | 01 | 1 | ZMK-04 | manual | `grep -n 'ZMK-04' .planning/REQUIREMENTS.md` | ✅ | ⬜ pending |
| 6-01-03 | 01 | 1 | PROV-02 | manual | `cat shell/.config/shell/config.d/path.darwin` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No new test infrastructure needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| ZMK-03 unchecked in v1, present in v2 without checkbox | ZMK-03 | Documentation change — no automated test possible | `grep -n 'ZMK-03' .planning/REQUIREMENTS.md` — confirm no `[x]` in v1 section, present in v2 section |
| ZMK-04 unchecked in v1, present in v2 without checkbox | ZMK-04 | Documentation change — no automated test possible | `grep -n 'ZMK-04' .planning/REQUIREMENTS.md` — confirm no `[x]` in v1 section, present in v2 section |
| path.darwin includes Intel Mac fallback | PROV-02 | Requires Intel Mac hardware to full verify | `cat shell/.config/shell/config.d/path.darwin` — confirm `elif [ -f /usr/local/bin/brew ]` present |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
