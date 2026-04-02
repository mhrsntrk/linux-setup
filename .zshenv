# =============================================================================
# ~/.zshenv - Environment variables for all shell invocations (Linux)
# =============================================================================

# PATH - Add user-specific binaries
export PATH="$HOME/.local/bin:$PATH"

# GPG TTY for proper GPG pinentry
export GPG_TTY=$(tty)

# Prevent duplicate PATH entries
typeset -gU path
