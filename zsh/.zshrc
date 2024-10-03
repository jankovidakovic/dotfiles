
# base config for oh my zsh
source /usr/share/oh-my-zsh/zshrc  # this sources the oh-my-zsh so we cannot configure plugins

#p10k instant prompt to make terminal open a bit snappier
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use powerline
USE_POWERLINE="true"  # what the fuck is this?

# set theme for zsh
ZSH_THEME="robbyrussell"

# Source manjaro-zsh-configuration
#
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
    source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
    source /usr/share/zsh/manjaro-zsh-prompt
fi

# fix for comment color on manjaro zsh theme
ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'

# user-defined overrides
[ -d ~/.config/zsh/config.d/ ] && source <(cat ~/.config/zsh/config.d/*)

# Fix for foot terminfo not installed on most servers
alias ssh="TERM=xterm-256color ssh"  # this is wild yo


# haskell ghc default environment
[ -f "/home/jvidakovic/.ghcup/env" ] && source "/home/jvidakovic/.ghcup/env" # ghcup-env

# SSH agent
# eval $(ssh-agent)
if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
	source /usr/share/nvm/init-nvm.sh
fi

if [[ -e "$HOME/.cargo/env" ]]; then
	source "$HOME/.cargo/env"
fi
