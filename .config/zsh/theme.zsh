# theme.zsh — Powerlevel10k prompt configuration (modular Zsh)
#
# Powerlevel10k is chosen for its unrivaled performance, modularity,
# visual clarity, and support for custom prompt segments. 
# The theme is set to use the Catppuccin Macchiato color palette for a modern and cohesive look—
# this improves readability and is aesthetically consistent across the dev workflow.
# Nerd Font icons/glyphs are enabled for Ghostty compatibility and visual cues.
#
# Prompt segments are minimal and performance-first: only essential info (user, host, dir, git, jj, status).
# The JJ (jujutsu) segment is added as a custom prompt element.
#
# For more segment and prompt structure tips, see: https://github.com/romkatv/powerlevel10k/blob/master/README.md#prompt-customization

# 1. Set color palette (Catppuccin Macchiato, mapped as close as possible)
# Colors taken from https://github.com/catppuccin/palette/blob/main/catppuccin-macchiato.palette.txt
# Powerlevel10k supports color customization—override base colors here for prompt segments.
# You may need to customize further for perfect accuracy with Ghostty, see Catppuccin docs.

# Catppuccin Macchiato (hex)
P10K_RESET='%f%k%b%F{242}'

# Base palette (approximate mapping for P10k)
export P10K_COLOR1="#24273a" # base
export P10K_COLOR2="#cad3f5" # text
export P10K_COLOR3="#f4dbd6" # rosewater
export P10K_COLOR4="#ed8796" # red
export P10K_COLOR5="#a6da95" # green
export P10K_COLOR6="#8aadf4" # blue
export P10K_COLOR7="#e0af68" # yellow
export P10K_COLOR8="#91d7e3" # teal
export P10K_COLOR9="#c6a0f6" # mauve
export P10K_COLOR10="#ee99a0" # flamingo

zmodload zsh/zle # needed for p10k keybinds

# 2. Source Powerlevel10k (should be loaded by plugin system already)
[[ -r "${ZDOTDIR:-$HOME}/.p10k.zsh" ]] && source "${ZDOTDIR:-$HOME}/.p10k.zsh"

# 3. Minimal prompt elements chosen for speed, clarity:
# Add custom 'jj_vcs' as the first segment for JJ status,
# followed by native git segment (for git repo info), then dir, status, etc.
# Set prompt segment order exclusively in ~/.p10k.zsh. Do not override here to avoid conflicts with the wizard or updates.
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(jj_vcs vcs dir dir_writable)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs)

# 4. Custom segment for JJ (jujutsu)
# We use a Powerlevel10k custom segment function. This must be defined in ~/.p10k.zsh or in theme.zsh itself.
# However, for best practices and maintainability, define it in jj.zsh and reference by segment name here.
# Example JJ segment:
# function prompt_jj_vcs() {
#   jj_prompt_info
# }
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS should contain 'jj_vcs' as a segment.
# Do NOT call $(jj_prompt_info) at load time (this is a shell command substitution, not a prompt callback).
#
# Instead, ensure your ~/.p10k.zsh (either regenerate via p10k configure or manually add):
# function prompt_jj_vcs() {
#   jj_prompt_info
# }
# and confirm it is in POWERLEVEL9K_LEFT_PROMPT_ELEMENTS.
#
# Rationale: This makes the JJ prompt dynamic and snappy without doing unnecessary work at load-time.

# 5. Enable icons and Nerd Font visuals
POWERLEVEL9K_MODE='nerdfont-complete'

# 6. Commented rationale:
# - Catppuccin Macchiato for cohesive, attractive, modern appearance
# - Only minimal/essential info (no distractions)
# - Custom segment order for ultra-fast visual scanning
# - All loaded colors are adjustable from one place for future tweaks
#
# Feel free to use a p10k wizard to generate a finely-tuned .p10k.zsh file for more granular preferences,
# but this setup provides a clean, high-contrast, visually consistent and fast prompt out-of-the-box.
