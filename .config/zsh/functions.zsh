# functions.zsh — Custom user/helper functions (modular Zsh)
#
# Currently empty for performance and simplicity. 
# Add frequently-used or personalized helpers here in the future.

# Auto-ls: Run ls after any directory change (works with cd, z, zoxide, etc)
function chpwd_autols() {
  eza --icons
}

# Register with Zsh's chpwd hooks
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_autols
