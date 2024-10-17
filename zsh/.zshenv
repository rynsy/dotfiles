alias termbin="nc termbin.com 9999"
alias gcm="git commit -m" 
alias gcl="git clone"
alias wifi="nmcli dev wifi connect"
alias apti="apt-get install -y"
alias aptu="apt-get upgrade -y"
alias python="python3"
alias pip="pip3"
alias yarn="yarnpkg"

export ZDOTDIR=~/.config/zsh
# Missing local bin
export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

# Color fixes
export LS_COLORS='ow=01;36;40'

# Install Ruby Gems to ~/.local/share/gem
export GEM_HOME="$HOME/.local/share/gem/ruby/3.2.0/bin"
export PATH="$PATH:$GEM_HOME"

# Composer setup
export PATH="$HOME/.composer/vendor/bin:$PATH"
alias search="fd --type f --hidden --exclude .git | fzf --reverse | xargs nvim"
alias search="fd --type f --hidden --exclude .git | fzf --reverse | xargs -r nvim"

