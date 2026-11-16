# ╔════════════════════════════════════════╗
# ║  CODE4U · zsh                          ║
# ╚════════════════════════════════════════╝
HISTFILE=~/.zsh_history; HISTSIZE=50000; SAVEHIST=50000
setopt append_history share_history hist_ignore_all_dups hist_ignore_space
setopt autocd interactive_comments no_beep extended_glob
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim VISUAL=nvim MANPAGER="sh -c 'col -bx | bat -l man -p'"
bindkey -e

# ---------- autocompletado ----------
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit -d ~/.cache/zcompdump
zmodload zsh/complist
zstyle ':completion:*' menu select                       # menú navegable con flechas/TAB
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'  # sin importar mayúsculas
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" 'ma=48;2;227;58;142;38;2;242;234;216'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format $'%F{#e33a8e}▌ %d%f'
zstyle ':completion:*:warnings' format $'%F{#d8323c}▌ sin coincidencias%f'
zstyle ':completion:*' use-cache on && zstyle ':completion:*' cache-path ~/.cache/zsh
bindkey -M menuselect '^[[Z' reverse-menu-complete      # SHIFT+TAB

# historial filtrado por lo que ya escribiste (↑ ↓)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search; bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word; bindkey '^[[1;5D' backward-word; bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line; bindkey '^[[F' end-of-line

# ---------- sugerencias (gris-azul, → para aceptar) ----------
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6b79d6'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---------- colores mientras escribes: verde = válido, rojo = no existe ----------
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]='fg=#7fd6a8,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#7fd6a8,bold'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#7fd6a8,bold'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#6bc9d6,bold'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#6bc9d6,italic'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#d8323c,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e33a8e'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#e33a8e'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ff7cbd'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ff7cbd'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f2c76b'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f2c76b'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#6bc9d6'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#f2ead8,underline'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#aab4f2'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#e33a8e'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#6b79d6,italic'
  ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#6b79d6'
  ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#e33a8e'
  ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#6bc9d6'
fi

# ---------- herramientas ----------
command -v fzf >/dev/null && source <(fzf --zsh) && export FZF_DEFAULT_OPTS="--color=bg+:#1b1f4a,bg:-1,fg:#aab4f2,fg+:#f2ead8,hl:#ff7cbd,hl+:#ff7cbd,pointer:#e33a8e,prompt:#e33a8e,marker:#7fd6a8,border:#6b79d6,info:#6b79d6 --border=sharp --prompt='❯ ' --pointer='▌'"
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first' ll='eza -l --icons --git --group-directories-first' la='eza -la --icons --git' lt='eza --tree --level=2 --icons'
fi
command -v bat >/dev/null && alias cat='bat -pp' && export BAT_THEME=base16
alias v=nvim vim=nvim lg=lazygit zj="zellij attach -c code4u" ff=fastfetch
alias pacs='sudo pacman -S' pacu='sudo pacman -Syu' pacr='sudo pacman -Rns'

# ---------- prompt ----------
if [[ $TERM != linux ]] && command -v starship >/dev/null; then eval "$(starship init zsh)"
else PROMPT=$'%F{#7fd6a8}%n%F{#aab4f2}@%F{#6b79d6}code4u %F{#aab4f2}%~\n%(?.%F{#e33a8e}.%F{#d8323c})❯%f '; fi

[[ -o interactive ]] && [[ -z "$ZELLIJ$ZELLIJ_SESSION_NAME" ]] && [[ "$(ps -o comm= -p $PPID)" != zellij* ]] && command -v fastfetch >/dev/null && fastfetch
