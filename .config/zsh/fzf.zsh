# =========================================================
# fzf
# =========================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results

# Ctrl-T uses fd
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# Ctrl-R searches history; Enter inserts the result without executing it.
export FZF_CTRL_R_OPTS="--no-preview --preview-window=hidden --header='History: Enter inserts, Esc cancels'"

dotfiles_load_fzf_history() {
  # Leave file/directory shortcuts alone; enable only the history widget.
  local FZF_CTRL_T_COMMAND='' FZF_ALT_C_COMMAND=''
  local bindings normal_ctrl_r
  normal_ctrl_r="$(bindkey -M vicmd '^R')"
  local -a normal_binding
  normal_binding=(${(z)normal_ctrl_r})
  for bindings in "${_DOTFILES_BREW_PREFIX:-/usr/local}/opt/fzf/shell/key-bindings.zsh" \
    /usr/share/fzf/key-bindings.zsh /usr/share/doc/fzf/examples/key-bindings.zsh; do
    if [[ -r "$bindings" ]]; then
      source "$bindings"
      # Retain normal-mode redo; Ctrl-R history is available in insert/emacs mode.
      bindkey -M vicmd '^R' "$normal_binding[-1]"
      return 0
    fi
  done
}
dotfiles_load_fzf_history
