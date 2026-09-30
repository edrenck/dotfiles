# SHARE_HISTORY already saves and imports entries across sessions.
setopt auto_cd
setopt auto_param_slash

setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt share_history
unsetopt beep

function chpwd_autols() {
  if command -v eza >/dev/null 2>&1; then
    eza --icons
  fi
}

# Register with Zsh's chpwd hooks
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_autols

