# Interactive Zsh bootstrap; shared configuration lives under .config/zsh.
if [[ -r "$HOME/.config/zsh/zshrc" ]]; then
  source "$HOME/.config/zsh/zshrc"
fi
# Per-machine settings and secrets belong in this ignored file.
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
