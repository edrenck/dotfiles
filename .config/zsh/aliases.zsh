# Optional tools should not remove the standard commands on a fresh machine.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons'
  alias ll='eza -lh --icons --git'
  alias la='eza -lah --icons --git'
  alias tree='eza --tree --icons'
  compdef eza=ls
fi
command -v lazygit >/dev/null 2>&1 && alias g='lazygit'
command -v lazydocker >/dev/null 2>&1 && alias d='lazydocker'
command -v zoxide >/dev/null 2>&1 && alias cd='z'
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v rg >/dev/null 2>&1 && alias grep='rg --color=auto'
alias df='df -h'
alias -- -='cd -'
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

lf() {
  local tmp dir
  tmp=$(mktemp) || return
  command lf -last-dir-path="$tmp" "$@"
  if [[ -f "$tmp" ]]; then
    dir=$(command cat "$tmp")
    command rm -f "$tmp"
    [[ -d "$dir" && "$dir" != "$PWD" ]] && builtin cd -- "$dir"
  fi
}
