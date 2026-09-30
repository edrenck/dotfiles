# Zsh setup

`~/.zshrc` sources `~/.config/zsh/zshrc`, which explicitly loads `.zshenv`
from this directory. Leave `ZDOTDIR` unset for this layout.

See the repository README for the Homebrew dependency command. Missing optional
tools leave the standard shell commands available. Plugin and completion caches
are generated locally; do not track them. History remains in `~/.history`.

The prompt reads `~/.config/starship.toml`. Per-machine overrides and credentials
belong in the ignored `~/.zshrc.local`, sourced after the shared configuration.
