---
phase: 3
slug: cross-platform-provisioning
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash + manual verification |
| **Config file** | none — shell scripts tested via execution |
| **Quick run command** | `bash -n install.sh` |
| **Full suite command** | Manual: run install.sh --minimal on fresh env |
| **Estimated runtime** | ~5 seconds (syntax checks) |

---

## Sampling Rate

- **After every task commit:** Run `bash -n install.sh` + file existence checks
- **After every plan wave:** Run `stow -n --no-folding <pkg>` dry-run for each new package
- **Before `/gsd:verify-work`:** Full suite must be green — stow all packages on Linux, verify sourcing in new shell
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | SHELL-01 | smoke | `bash -c 'source ~/.config/shell/config.d/alias && type n'` | ❌ W0 | ⬜ pending |
| 03-01-02 | 01 | 1 | SHELL-02 | smoke | `bash -c '. ~/.config/shell/config.d/path && echo $PATH'` | ❌ W0 | ⬜ pending |
| 03-02-01 | 02 | 2 | PROV-01 | manual-only | Run on fresh Arch VM/container | N/A | ⬜ pending |
| 03-02-02 | 02 | 2 | PROV-02 | manual-only | Run on fresh macOS | N/A | ⬜ pending |
| 03-02-03 | 02 | 2 | PROV-04 | unit | `bash -n install.sh && grep -q 'CORE_' install.sh` | ❌ W0 | ⬜ pending |
| 03-03-01 | 03 | 3 | PSH-01 | smoke | `test -f powershell/.config/powershell/profile.ps1` | ❌ W0 | ⬜ pending |
| 03-03-02 | 03 | 3 | PSH-02 | smoke | `pwsh -c '. ~/.config/powershell/profile.ps1; Get-Alias n'` | ❌ W0 | ⬜ pending |
| 03-03-03 | 03 | 3 | PSH-03 | manual-only | Run on Windows + Mac + Linux | N/A | ⬜ pending |
| 03-03-04 | 03 | 3 | PROV-03 | manual-only | Run on fresh Windows | N/A | ⬜ pending |
| 03-04-01 | 04 | 3 | APP-01 | smoke | `test -f alacritty/.config/alacritty/alacritty.toml && grep -q 'import' alacritty/.config/alacritty/alacritty.toml` | ❌ W0 | ⬜ pending |
| 03-04-02 | 04 | 3 | APP-02 | smoke | `grep -q 'linux.toml' alacritty/.config/alacritty/alacritty.toml` | ❌ W0 | ⬜ pending |
| 03-04-03 | 04 | 3 | XPLAT-01 | smoke | Verify import/include in each app config | ❌ W0 | ⬜ pending |
| 03-05-01 | 05 | 4 | XPLAT-02 | smoke | `grep -q 'install.sh' README.md && grep -q 'install.ps1' README.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] No automated test framework needed — validation uses bash syntax checks and file existence smoke tests
- [ ] `stow -n --no-folding shell` — dry-run to verify no conflicts (run after shell/ created)
- [ ] `bash -n install.sh` — syntax validation after modifications

*Existing infrastructure (bash, stow) covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| install.sh --minimal on Arch | PROV-01 | Requires fresh Arch environment | Boot Arch VM/container, clone repo, run `./install.sh --minimal`, verify zsh/tmux/nvim installed |
| install.sh on macOS | PROV-02 | Requires macOS hardware/VM | Clone repo on Mac, run `./install.sh`, verify Homebrew + packages installed |
| install.ps1 on Windows | PROV-03 | Requires Windows environment | Open PowerShell as admin, run `.\install.ps1`, verify symlinks + winget packages |
| PowerShell cross-platform | PSH-03 | Requires multiple OS environments | Source profile on Windows, Mac, Linux — verify aliases work |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
