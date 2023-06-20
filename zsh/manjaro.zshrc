# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# Missing local bin
export PATH="$HOME/.local/bin:$PATH"

# Color fixes
#export LS_COLORS='ow=01;36;40'

# Cargo bin
export CARGO_HOME="$HOME/.cargo/"
export PATH="$CARGO_HOME/bin/:$PATH"

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/.local/share/gem/ruby/3.0.0/"
export PATH="$GEM_HOME:$PATH"

# Composer setup
export COMPOSER_HOME="$HOME/.composer/vendor/bin"
export PATH="$COMPOSER_HOME:$PATH"

newgrp docker # Not totally necessary, but need a workaround to use docker without sudo

