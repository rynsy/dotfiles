# PowerShell Profile
# Mirrors aliases from ~/.config/shell/config.d/alias but maintained independently.
# PowerShell uses its own idioms (functions, Set-Alias) — these are equivalent
# shortcuts, not generated from the shared shell config. Drift is acceptable.

# --- Git aliases ---

# Remove built-in gcm alias (Get-Command) before redefining
Remove-Alias gcm -Force -ErrorAction SilentlyContinue

function gcm { git commit -m @args }
function gcl { git clone @args }

# --- Editor ---

Set-Alias -Name n -Value nvim

# --- Tmux ---

function t { tmux new -As workspace }
function ta { tmux attach -t workspace }

# --- Docker ---

Set-Alias -Name dc -Value docker-compose

# --- Directory shortcuts (platform-aware paths) ---

if ($IsWindows) {
    function lab { Set-Location "$env:USERPROFILE\code\lab" }
    function proj { Set-Location "$env:USERPROFILE\code\projects" }
    function study { Set-Location "$env:USERPROFILE\code\study" }
    function cdar { Set-Location "$env:USERPROFILE\code\cdar" }
} else {
    function lab { Set-Location "$HOME/code/lab" }
    function proj { Set-Location "$HOME/code/projects" }
    function study { Set-Location "$HOME/code/study" }
    function cdar { Set-Location "$HOME/code/cdar" }
}

Set-Alias -Name s -Value study
Set-Alias -Name p -Value proj

# --- Language defaults ---

Set-Alias -Name python -Value python3 -ErrorAction SilentlyContinue
