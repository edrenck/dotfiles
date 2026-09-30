# Zsh setup

`~/.zshrc` sources `~/.config/zsh/zshrc`, which explicitly loads `.zshenv`
from this directory. Leave `ZDOTDIR` unset for this layout.

The root README lists the Homebrew dependencies. Antidote manages:

- `zsh-completions`: extra command-specific completion definitions.
- `zsh-vi-mode`: the existing Vim-style editing modes, initialized at load time.
- `zsh-autosuggestions`: visible grey suggestions from your command history.
- `fast-syntax-highlighting`: command-line syntax highlighting.

Completion definitions load before `compinit`; vi-mode initializes before history
and suggestion widgets. Tab remains standard Zsh completion. The old unbound
history-substring-search plugin is replaced by fzf's searchable history widget.

Use Ctrl-R in insert/emacs mode to filter history. Enter inserts the selected
command so you can review it; Esc cancels. Normal-mode Ctrl-R remains redo.
Accept a grey suggestion with Right Arrow or End at the end of the command line.
Existing aliases and other shortcut bindings are retained.

History remains in `~/.history`, shared across shells. Generated completion and
Antidote loading caches live in `~/.cache/zsh` and are not tracked. Insecure
completion directories are ignored; `compaudit` can identify permission problems.

The prompt reads `~/.config/starship.toml`. It shows directory, Git branch/status,
relevant language versions, slow-command duration, and a separate input line.
Per-machine overrides and credentials belong in the ignored `~/.zshrc.local`,
sourced after the shared configuration. Open a new shell after updating plugins.
