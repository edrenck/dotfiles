# env.zsh — Environment variables and completions (modular Zsh)
#
# Loads language-specific environment settings and per-tool completions so that
# all plugins and the theme have access to them early in the load order.
# Only essential completions and environment variables for active development languages/tools are set here,
# and only lightweight logic is used to avoid sacrificing shell startup performance.

# --------------------------
# PATH and Language Env Setup
# --------------------------

# Add Homebrew to PATH if installed (Apple Silicon first, then Intel fallback)
if [ -d /opt/homebrew/bin ]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [ -d /usr/local/bin ]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Add user-local bin to PATH (standard best practice for modern CLI setup)
export PATH="$HOME/.local/bin:$PATH"
# Go, Kotlin, and Java typically do not need env setup here unless you want to set GOPATH, JAVA_HOME, etc.

# --------------------------
# Completions for Language Tools (Node, Go, Java, Kotlin)
# --------------------------
# Only loaded if the relevant binary is present for max efficiency.

