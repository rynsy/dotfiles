---
phase: 5
slug: alacritty-platform-fix
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification (shell + config file inspection) |
| **Config file** | none — dotfiles project, no test runner |
| **Quick run command** | `grep -c 'font.size\|\.local/bin\|\.cargo/bin' alacritty/.config/alacritty/*.toml zsh/.zshenv shell/.config/shell/config.d/path 2>/dev/null` |
| **Full suite command** | Manual: verify file existence, content, PATH on each platform |
| **Estimated runtime** | ~2 seconds (grep commands) |

---

## Sampling Rate

- **After every task commit:** Run quick grep command to verify file contents
- **After every plan wave:** Verify alacritty.toml uses `[general]` import, no deprecated root import; verify .zshenv has no PATH; verify shell/path has entries
- **Before `/gsd:verify-work`:** Full manual verification must pass
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | APP-01 | smoke | `ls alacritty/.config/alacritty/ && ls alacritty/platform/` | N/A | ⬜ pending |
| 05-01-02 | 01 | 1 | APP-01, XPLAT-01 | smoke | `grep -n '\[general\]' alacritty/.config/alacritty/alacritty.toml && grep -n 'import' alacritty/.config/alacritty/alacritty.toml` | N/A | ⬜ pending |
| 05-01-03 | 01 | 1 | APP-02 | smoke | `grep 'font.size' alacritty/platform/macos.toml alacritty/platform/linux.toml` | N/A | ⬜ pending |
| 05-01-04 | 01 | 1 | XPLAT-01 | smoke | `! grep -q 'font.size' alacritty/.config/alacritty/alacritty.toml` | N/A | ⬜ pending |
| 05-01-05 | 01 | 1 | XPLAT-01 | smoke | `grep -c 'alacritty/platform' install.sh` | N/A | ⬜ pending |
| 05-01-06 | 01 | 1 | XPLAT-01 | smoke | `! grep -qE '\.local/bin\|\.cargo/bin' zsh/.zshenv && grep -qE '\.local/bin\|\.cargo/bin' shell/.config/shell/config.d/path` | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No test framework needed — verification is file inspection and manual testing.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Alacritty displays correct font size on macOS (13pt) | APP-02 | Requires macOS machine | Launch Alacritty on macOS, verify font renders at 13pt |
| Alacritty displays correct font size on Linux (9pt) | APP-02 | Requires visual inspection | Launch Alacritty on Linux, verify font renders at 9pt |
| Missing platform import file silently skipped | XPLAT-01 | Requires Alacritty runtime | Launch Alacritty with only one platform file present, check no errors |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
