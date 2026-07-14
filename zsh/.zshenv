export ZDOTDIR=~/.config/zsh

# Answer ssh password prompts from the login keyring (service 'ssh-servers',
# key host=<hostname>). Falls back to a normal terminal prompt for anything not
# stored, so key-based hosts and passphrases are unaffected. Helper: ~/.ssh/keyring-askpass
export SSH_ASKPASS="$HOME/.ssh/keyring-askpass"
export SSH_ASKPASS_REQUIRE=force
