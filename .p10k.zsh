# ➜ Catppuccin Macchiato Color Palette for Powerlevel10k

# Catppuccin base colors
typeset -g CP_ROSEWATER=#f4dbd6
typeset -g CP_FLAMINGO=#f0c6c6
typeset -g CP_PINK=#f5bde6
typeset -g CP_MAUVE=#c6a0f6
typeset -g CP_RED=#ed8796
typeset -g CP_MAROON=#ee99a0
typeset -g CP_PEACH=#f5a97f
typeset -g CP_YELLOW=#eed49f
typeset -g CP_GREEN=#a6da95
typeset -g CP_TEAL=#8bd5ca
typeset -g CP_SKY=#91d7e3
typeset -g CP_SAPPHIRE=#7dc4e4
typeset -g CP_BLUE=#8aadf4
typeset -g CP_LAVENDER=#b7bdf8
typeset -g CP_TEXT=#cad3f5
typeset -g CP_SUBTEXT1=#b8c0e0
typeset -g CP_SUBTEXT0=#a5adcb
typeset -g CP_OVERLAY2=#939ab7
typeset -g CP_OVERLAY1=#8087a2
typeset -g CP_OVERLAY0=#6e738d
typeset -g CP_SURFACE2=#5b6078
typeset -g CP_SURFACE1=#494d64
typeset -g CP_SURFACE0=#363a4f
typeset -g CP_BASE=#24273a
typeset -g CP_MANTLE=#1e2030
typeset -g CP_CRUST=#181926

# ➜ Powerlevel10k prompt settings: compact, two-line, modern/riced features

# Disable multiline prefix for a clean two-line look
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='❯'

# Pellet-style (pill/gap) segments
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true


# Ensure prompt char appears on second line
typeset -g POWERLEVEL9K_PROMPT_CHAR='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_FOREGROUND=$CP_LAVENDER
typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=$CP_BASE
# Transient prompt: old prompts collapse to 1 line
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# Rainbow segment order (left): os_icon | context | dir | vcs | venv/kube/cloud
# Rainbow segment order (right): ram | jobs | battery | time | status

# Left prompt segments
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon dir vcs virtualenv kubecontext aws gcloud
)
# Right prompt segments
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  context ram jobs status
)

# Segment color assignments (bg/fg using Catppuccin Macchiato)
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$CP_MAUVE
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$CP_SURFACE0

typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$CP_PINK
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$CP_BLUE
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

typeset -g POWERLEVEL9K_DIR_FOREGROUND=$CP_TEXT
typeset -g POWERLEVEL9K_DIR_BACKGROUND=$CP_BLUE
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$CP_YELLOW

typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$CP_GREEN
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$CP_BASE
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$CP_YELLOW
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$CP_BASE
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$CP_RED
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$CP_BASE

typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$CP_TEXT
typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$CP_TEAL

typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=$CP_TEXT
typeset -g POWERLEVEL9K_KUBECONTEXT_BACKGROUND=$CP_SAPPHIRE
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens'

typeset -g POWERLEVEL9K_AWS_FOREGROUND=$CP_BASE
typeset -g POWERLEVEL9K_AWS_BACKGROUND=$CP_YELLOW
typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|terraform'

typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=$CP_BASE
typeset -g POWERLEVEL9K_GCLOUD_BACKGROUND=$CP_SKY
typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gsutil'

typeset -g POWERLEVEL9K_RAM_FOREGROUND=$CP_BASE
typeset -g POWERLEVEL9K_RAM_BACKGROUND=$CP_LAVENDER

typeset -g POWERLEVEL9K_JOBS_FOREGROUND=$CP_TEXT
typeset -g POWERLEVEL9K_JOBS_BACKGROUND=$CP_MAROON

typeset -g POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_BATTERY_CHARGING_BACKGROUND=$CP_GREEN
typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_BACKGROUND=$CP_YELLOW
typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_BATTERY_LOW_BACKGROUND=$CP_RED

typeset -g POWERLEVEL9K_TIME_FOREGROUND=$CP_TEXT
typeset -g POWERLEVEL9K_TIME_BACKGROUND=$CP_PEACH
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=$CP_GREEN
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$CP_SURFACE0
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$CP_RED

typeset -g POWERLEVEL9K_PROMPT_CHAR_FOREGROUND=$CP_LAVENDER
typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=$CP_BASE

# ➜ Other ricer/quality-of-life options
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
typeset -g POWERLEVEL9K_LOCK_ICON=''
typeset -g POWERLEVEL9K_HOME_ICON=''
typeset -g POWERLEVEL9K_FOLDER_ICON=''
typeset -g POWERLEVEL9K_ETC_ICON=''

# (Optional) Segments only shown on specific commands are controlled by SHOW_ON_COMMAND strings
# To always show, just comment/remove the variable
# To add more rainbow or info segments, see the full Powerlevel10k doc for segment list

autoload -Uz is-at-least
if ! is-at-least 5.7.1; then
  for v in $(set | grep '^CP_' | cut -d= -f1); do
    typeset -g $v=$(print -P %F{${(P)v}})
  done
fi

# ➜ That's it! Reload zsh after copying this to ~/.p10k.zsh (or source ~/.p10k.zsh)
# Tweak segment order and icons above as you further rice your prompt.
