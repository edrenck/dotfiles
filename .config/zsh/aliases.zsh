# aliases.zsh — Essential alias overrides (modular Zsh)
#
# Keeps commonly-used commands modern and consistent. 
# All choices favor improved UX, functionality, or performance over the traditional default.

alias vim="nvim"        # Modern Neovim instead of legacy Vim
alias cat="bat"         # Bat for syntax-highlighted and paged cat output

alias ls="eza --icons"          # eza over ls for icons, filetypes, git info
alias cd='z'  # use zoxide/z for smart directory changing
