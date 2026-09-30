# Shared environment, explicitly sourced by .config/zsh/zshrc.
# This path is not an automatic Zsh startup file while ZDOTDIR is unset.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
