# Phase 5: Alacritty Platform Config Fix - Research

**Researched:** 2026-03-08
**Domain:** Alacritty terminal configuration, GNU Stow cross-platform file management, zsh PATH management
**Confidence:** HIGH

## Summary

Phase 5 closes two integration bugs discovered during the v1.0 audit: (1) Alacritty's platform-include pattern is broken because stow places ALL platform config files on every machine, and Alacritty's import mechanism has no platform-conditional loading, and (2) PATH entries for `.local/bin` and `.cargo/bin` are defined in both `zsh/.zshenv` and `shell/.config/shell/config.d/path`, causing duplication.

The Alacritty bug is structural: unlike Ghostty (where macOS-only config keys like `macos-titlebar-style` are no-ops on Linux), Alacritty's `macos.toml` contains `font.size = 13.0` which is a universal setting that applies on all platforms. Since stow symlinks all files in the package, both `linux.toml` and `macos.toml` exist on every machine. Alacritty imports are loaded in order with the base config loading last (overriding everything), but when font.size is removed from the base to let platform files control it, both platform files still load and the last-listed one wins unconditionally.

The PATH bug is straightforward: `.zshenv` sets `$HOME/.local/bin` and `$HOME/.cargo/bin` in PATH before `.zshrc` sources `shell/.config/shell/config.d/path`, which adds them again. The fix is to remove the PATH line from `.zshenv` and rely solely on the shared config.

**Primary recommendation:** Move platform TOML files out of the stow directory tree into a non-stowed location (e.g., `alacritty/platform/`); have `install.sh` copy the correct platform file to `~/.config/alacritty/` based on OS detection. Remove duplicate PATH entries from `.zshenv`. Also migrate `import` from deprecated root level to `[general]` section.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| APP-01 | `alacritty/` stow package with platform-specific config includes (mirrors ghostty pattern) | Research shows the Ghostty pattern cannot be directly mirrored for Alacritty because Alacritty has no platform-scoped config keys. Platform files must be placed by install.sh, not stowed. See Architecture Patterns. |
| APP-02 | Alacritty config is cross-platform (Linux/Mac/Windows paths handled) | Base config works everywhere; platform files provide OS-specific overrides. `option_as_alt` is macOS-only and harmless on other platforms. Font size varies by platform. |
| XPLAT-01 | Each app config follows the platform-include pattern (base config + optional platform overrides) | The import mechanism works correctly when only the right platform file exists. install.sh handles placement. Pattern preserved, implementation adapted. |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Alacritty | 0.16.1 | Terminal emulator | Already installed, config uses TOML format |
| GNU Stow | system | Symlink manager | Project standard for dotfile management |
| install.sh | N/A | Bootstrap script | Already handles platform detection and package stowing |

### Configuration Format
| Format | Where | Notes |
|--------|-------|-------|
| TOML | Alacritty config | Alacritty 0.13+ migrated from YAML to TOML |
| `[general]` section | Import declarations | Since 0.14, `import` must be under `[general]`, not root level |

## Architecture Patterns

### Current State (Broken)

```
alacritty/.config/alacritty/
  alacritty.toml     # base config - imports both platform files, font.size=9.0
  linux.toml          # placeholder (empty)
  macos.toml          # font.size=13.0, option_as_alt=Both
```

**Why it is broken:** `stow --no-folding alacritty` symlinks ALL three files to `~/.config/alacritty/`. On Linux, `macos.toml` exists and gets imported. However, per Alacritty docs, "the importing file is loaded last" -- so the base config's `font.size = 9.0` would actually override `macos.toml`'s 13.0. This means:
- On Linux: font size is 9.0 (correct by accident, but `option_as_alt` still loads pointlessly)
- On macOS: font size is 9.0 (WRONG -- should be 13.0 because the base overrides the import)

The fundamental problem is that Alacritty's import mechanism cannot provide platform-specific overrides because the base config always wins. The current config structure gives the false impression that `macos.toml` overrides the base, but it actually does not.

Additionally, the `import` field is at the TOML root level, which is deprecated since Alacritty 0.14 (current version is 0.16.1).

### Recommended Fix: Platform File Placement via install.sh

```
alacritty/
  .config/alacritty/
    alacritty.toml       # base config - imports platform files (missing ones skipped)
  platform/
    linux.toml            # Linux overrides (currently empty/placeholder)
    macos.toml            # macOS overrides (font.size=13.0, option_as_alt)
```

**How it works:**
1. `stow --no-folding alacritty` only symlinks `alacritty.toml` (the `platform/` dir is outside the `.config/` tree, so stow ignores it for symlinking purposes)
2. `install.sh` detects OS and copies the correct platform file:
   - Linux: copies `platform/linux.toml` to `~/.config/alacritty/linux.toml`
   - macOS: copies `platform/macos.toml` to `~/.config/alacritty/macos.toml`
3. Base config imports both `linux.toml` and `macos.toml` -- the missing one is silently skipped
4. The present platform file loads first, then the base config loads last
5. Settings that must vary by platform (font.size) go ONLY in platform files, NOT in the base config
6. The base config sets universal defaults only (font family, padding, cursor)

**Key insight:** For the platform import to actually work, `font.size` must be REMOVED from the base `alacritty.toml`. The base config loads last and overrides imports, so any value in the base would clobber the platform-specific value.

### Alacritty Import Precedence (Verified from Official Docs)

Load order: imported files in list order, then the importing (base) file last.

```
1. ~/.config/alacritty/linux.toml   (if exists)
2. ~/.config/alacritty/macos.toml   (if exists -- skipped if missing)
3. ~/.config/alacritty/alacritty.toml  (base -- loads LAST, wins on conflicts)
```

**Critical rule:** Any setting in the base config WILL override the same setting in imported files. Platform-varying settings MUST NOT appear in the base config.

### Alacritty [general] Migration

Since Alacritty 0.14, `import` at the root level is deprecated. The current config:

```toml
# DEPRECATED (current)
import = [
  "~/.config/alacritty/linux.toml",
  "~/.config/alacritty/macos.toml",
]
```

Must become:

```toml
# CORRECT (0.14+)
[general]
import = [
  "~/.config/alacritty/linux.toml",
  "~/.config/alacritty/macos.toml",
]
```

### Why Ghostty Works But Alacritty Does Not

Ghostty's platform-include pattern works with stow because:
1. `macos.conf` contains only macOS-scoped settings (`macos-titlebar-style`, `window-theme`, `keybind = cmd+b`)
2. These settings are **no-ops on Linux** -- Ghostty ignores macOS-only keys on non-macOS platforms
3. `linux.conf` contains only Linux-scoped settings (`gtk-toolbar-style`)
4. Neither file overrides universal settings like font-size

Alacritty's `macos.toml` contains `font.size = 13.0`, which is NOT macOS-scoped -- Alacritty applies it on any platform. This is the root cause of the incompatibility.

### Anti-Patterns to Avoid
- **Putting platform-varying values in the base Alacritty config:** The base loads last and always wins, making imports useless for overrides
- **Using `.stow-local-ignore` for platform exclusion:** Stow ignore patterns are static regex, not platform-conditional
- **Separate stow packages per platform:** Over-engineered; install.sh already has OS detection

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Platform detection | Custom detection logic | Existing `OS="$(uname -s)"` in install.sh | Already proven, handles Linux/Darwin |
| Config file placement | Manual cp commands scattered in script | Structured section in install.sh after stow | Keeps all platform logic in one place |
| TOML migration | Manual editing for deprecated fields | `alacritty migrate` command | Built-in tool that handles all deprecated fields |

## Common Pitfalls

### Pitfall 1: Assuming Imports Override the Base Config
**What goes wrong:** Developer puts `font.size = 9.0` in both the base config AND `linux.toml`, expecting `macos.toml`'s `font.size = 13.0` to win on macOS.
**Why it happens:** Intuition says "imports override base" but Alacritty does the opposite -- the base (importing file) loads last.
**How to avoid:** Platform-varying settings ONLY in platform files, NEVER in the base config.
**Warning signs:** Same key appears in both base and platform files.

### Pitfall 2: Forgetting That Stow Symlinks Everything
**What goes wrong:** Adding a macOS-only file to the stow package tree, expecting it to only appear on macOS.
**Why it happens:** Stow has no platform awareness -- it symlinks all files in the package directory.
**How to avoid:** Keep platform files outside the stow tree (e.g., `alacritty/platform/`). Use install.sh for platform-conditional placement.
**Warning signs:** Platform files exist at `~/.config/alacritty/` on the wrong OS.

### Pitfall 3: PATH Duplication Across Shell Init Files
**What goes wrong:** `.zshenv` and shared `path` config both add the same directories to PATH.
**Why it happens:** `.zshenv` was written before the shared shell config was created in Phase 3. The shared config added the same entries without cleaning up `.zshenv`.
**How to avoid:** Single source of truth for PATH entries. `.zshenv` should only set `ZDOTDIR`.
**Warning signs:** `echo $PATH | tr ':' '\n' | sort | uniq -d` shows duplicates.

### Pitfall 4: Deprecated Root-Level Import
**What goes wrong:** Alacritty shows deprecation warning: "import has been deprecated; use general.import instead"
**Why it happens:** Config was written for Alacritty 0.13 format; 0.14+ moved `import` to `[general]` section.
**How to avoid:** Use `[general]` section for `import`. Run `alacritty migrate` to auto-fix.
**Warning signs:** Warning in Alacritty log output.

## Code Examples

### Fixed alacritty.toml (base config)
```toml
# Source: Alacritty 0.16 config format (https://alacritty.org/config-alacritty.html)
# Base Alacritty config
# Platform-specific overrides imported below (missing files silently skipped)
[general]
import = [
  "~/.config/alacritty/linux.toml",
  "~/.config/alacritty/macos.toml",
]

[font]
normal = { family = "CaskaydiaMono Nerd Font", style = "Regular" }
# NOTE: font.size is set in platform files, NOT here (base loads last and would override)

[window]
padding = { x = 14, y = 14 }

[cursor]
style = { shape = "Block", blinking = "Off" }
```

### Fixed macos.toml (platform file)
```toml
# macOS-specific Alacritty settings
# Placed by install.sh -- not stowed directly

[font]
size = 13.0

[window]
option_as_alt = "Both"
```

### Fixed linux.toml (platform file)
```toml
# Linux-specific Alacritty settings
# Placed by install.sh -- not stowed directly

[font]
size = 9.0
```

### install.sh platform file placement (after stow loop)
```bash
# Source: project convention for platform-specific config placement
# Place platform-specific Alacritty config
if [ -d "$DOTFILES_DIR/alacritty/platform" ]; then
  case "$OS" in
    Linux)
      cp "$DOTFILES_DIR/alacritty/platform/linux.toml" "$HOME/.config/alacritty/linux.toml"
      ;;
    Darwin)
      cp "$DOTFILES_DIR/alacritty/platform/macos.toml" "$HOME/.config/alacritty/macos.toml"
      ;;
  esac
fi
```

### Fixed .zshenv
```bash
# Source: project convention -- ZDOTDIR only, PATH handled by shared config
export ZDOTDIR=~/.config/zsh
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Root-level `import = [...]` | `[general]` section `import` | Alacritty 0.14 (2024) | Deprecation warning on 0.14+; must use `[general]` |
| YAML config | TOML config | Alacritty 0.13 (2023) | Old YAML format auto-migrated but deprecated |

**Deprecated/outdated:**
- Root-level `import`: deprecated since 0.14, must be under `[general]`
- YAML config format: deprecated since 0.13

## Open Questions

1. **Should linux.toml explicitly set font.size = 9.0 or omit it?**
   - What we know: If font.size is omitted from both the base config and the platform file, Alacritty uses its built-in default (which varies by platform). On Linux, the default font family is "monospace" at size 11.25.
   - Recommendation: Explicitly set `font.size = 9.0` in `linux.toml` to be explicit about the intended value, matching the current base config's intent.

2. **Should install.sh copy platform files or symlink them?**
   - What we know: `cp` creates an independent copy that won't update when the dotfiles repo changes. A symlink would track changes but adds complexity.
   - Recommendation: Use `ln -sf` (symlink) for consistency with stow's approach. The file path `$DOTFILES_DIR/alacritty/platform/linux.toml` is stable.

3. **Does the omarchy Alacritty config on this machine need consideration?**
   - What we know: The deployed `~/.config/alacritty/alacritty.toml` on this Linux machine is NOT from the stow package -- it's an omarchy-managed file with different content (imports omarchy theme, has keyboard bindings, etc.)
   - Recommendation: The stow package's conflict detection in install.sh already handles this. The fix is to the stow package source files, not the deployed state. When stowed, the conflict checker will back up the omarchy file.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification (shell + config file inspection) |
| Config file | N/A -- dotfiles project, no test runner |
| Quick run command | `grep -c 'font.size\|\.local/bin\|\.cargo/bin' ~/.config/alacritty/*.toml zsh/.zshenv shell/.config/shell/config.d/path 2>/dev/null` |
| Full suite command | Manual: verify file existence, content, and PATH on each platform |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| APP-01 | Alacritty stow package has base config; platform files placed by install.sh | smoke | `ls -la ~/.config/alacritty/` to verify only base + correct platform file exist | N/A -- manual |
| APP-02 | Alacritty config works cross-platform | manual-only | Run Alacritty on each platform, verify font size | N/A -- requires multi-platform |
| XPLAT-01 | Platform-include pattern: base imports, missing files skipped | smoke | `alacritty --print-events 2>&1 \| head -5` to check for import warnings | N/A -- manual |

### Sampling Rate
- **Per task commit:** Verify file contents with grep/cat
- **Per wave merge:** Check alacritty.toml uses `[general]` import, no deprecated root import; verify .zshenv has no PATH; verify shell/path has entries
- **Phase gate:** `echo $PATH | tr ':' '\n' | sort | uniq -d` shows no duplicates for .local/bin or .cargo/bin

### Wave 0 Gaps
- None -- no test infrastructure needed. Verification is file inspection and manual testing.

## Sources

### Primary (HIGH confidence)
- [Alacritty official config docs](https://alacritty.org/config-alacritty.html) - import semantics, [general] section, option_as_alt
- [Alacritty man page (Arch)](https://man.archlinux.org/man/alacritty.5) - import precedence: "importing file loaded last"
- [GNU Stow manual - Ignore Lists](https://www.gnu.org/software/stow/manual/html_node/Types-And-Syntax-Of-Ignore-Lists.html) - .stow-local-ignore is static regex, not platform-conditional
- Local file inspection - alacritty/, ghostty/, zsh/, shell/ packages in the dotfiles repo

### Secondary (MEDIUM confidence)
- [Alacritty PR #8192](https://github.com/alacritty/alacritty/pull/8192) - root fields moved to [general] section
- [Alacritty issue #6996](https://github.com/alacritty/alacritty/issues/6996) - import deprecation warning details
- [Alacritty ArchWiki](https://wiki.archlinux.org/title/Alacritty) - configuration file locations

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Alacritty version verified locally (0.16.1), docs checked
- Architecture: HIGH - Import precedence verified from official docs + man page; Ghostty comparison verified by reading actual config files
- Pitfalls: HIGH - PATH duplication confirmed by reading both .zshenv and shell/path; import override behavior confirmed from multiple sources

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (stable domain -- Alacritty config format unlikely to change)
