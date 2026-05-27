setopt inc_append_history
setopt auto_cd
setopt auto_param_slash

setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt share_history
unsetopt beep

function chpwd_autols() {
  eza --icons
}

# Register with Zsh's chpwd hooks
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_autols

