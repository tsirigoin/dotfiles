# --- Zinit Setup ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if it's missing
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 4 numeric
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/home/tsiri/.zshrc'
# Colorize the completion menu using your system colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Case-insensitive completion (so 'cd down' finds 'Downloads')
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Oh My Zsh Snippets & Plugins ---
# OMZL = Oh My Zsh Library, OMZP = Oh My Zsh Plugin

zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load the essential UI plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting

autoload -Uz compinit
compinit
# Allow Zinit to replay completions it has cached
zinit cdreplay -q
# End of lines added by compinstall

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
# sharehistory: immediately share history between all open tabs
# hist_ignore_all_dups: don't save the same command twice
# hist_ignore_space: don't save commands that start with a space
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify       # Let me edit the command after using history expansion
setopt autocd extendedglob nomatch notify
unsetopt beep
# End of lines configured by zsh-newuser-install

# --- Keybinds ---
bindkey -e                                 # Use Emacs mode (standard)

# Basic navigation
bindkey '^p' history-search-backward       # Partial history search
bindkey '^n' history-search-forward
bindkey '^[[3~' delete-char                # Fix Delete key

# The "Word-by-Word" Fix (Alt + key)
bindkey "^[[1;3C" forward-word             # Alt + Right
bindkey "^[[1;3D" backward-word            # Alt + Left
bindkey "^[f" forward-word                 # macOS/Meta + Right
bindkey "^[b" backward-word                # macOS/Meta + Left

bindkey '^[[3;3~' kill-word								# Alt + Delete (kill word)

# --- Homebrew Setup ---
if [[ "$(uname)" == "Darwin" ]]; then
    BREW_BIN="/opt/homebrew/bin"
else
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
fi

# Only initialize if brew exists at that path
if [[ -f "$BREW_BIN/brew" ]]; then
    eval "$($BREW_BIN/brew shellenv)"
fi

# --- Aliases ---
alias ls='ls --color=auto'
alias ll='ls -la'
alias vim='nvim'
alias c='clear'
alias cat='bat -p'
alias man='batman'
alias config='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'

# System-specific (Arch/Endeavour)
if command -v archstatus &> /dev/null; then
    alias archstatus='archstatus -l endeavouros'
fi

# --- External Tool Integrations ---

sync_init() {
    local tool=$1
    local cmd=$2
    local cache_file="$HOME/.zsh_cache/${tool}_init.zsh"

    if command -v "$tool" &> /dev/null; then
        # If cache doesn't exist, create it once
        if [[ ! -f "$cache_file" ]]; then
            eval "$cmd" > "$cache_file"
        fi
        source "$cache_file"
    fi
}

# Now call them (this only runs the 'eval' if the file is missing)
sync_init "zoxide" "zoxide init --cmd cd zsh"
sync_init "fzf" "fzf --zsh"
sync_init "atuin" "atuin init zsh"
sync_init "oh-my-posh" "oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml"

# Special case for Carapace (it's often updated, so we source it directly)
if command -v carapace &> /dev/null; then
    source <(carapace _carapace)
fi

# --- Prompt ---
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
fi