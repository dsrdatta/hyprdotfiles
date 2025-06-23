
# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

export PATH="$HOME/Projects/myscripts:$PATH"
export PATH="$HOME/go/bin:$PATH"

#my settings
export EDITOR="nvim"
alias update-pkglist='pacman -Qqen > ~/dotfiles/pkglist.txt && yay -Qqem > ~/dotfiles/aurlist.txt'

alias ll='ls -lah'
alias vim='nvim'
# export GOPATH=$HOME/go
# export GOBIN=$HOME/go/bin

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(zoxide init --cmd cd zsh)"
