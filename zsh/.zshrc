#!/usr/bin/env zsh

### ----------------------------
### Defaults
### ----------------------------

# Editor
export VISUAL=hx
export EDITOR=$VISUAL

# Git-grab pattern
# See: https://github.com/bezbac/git-grab
export GRAB_PATTERN="~/dev/repos/{owner/}{repo}"

### ----------------------------
### Source stuff
### ----------------------------

# Add homebrew binaries to path
export PATH="/opt/homebrew/bin:$PATH"

# Sheldon
eval "$(sheldon source)"

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Atuin
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

### ----------------------------
### Keybindings
### ----------------------------

# Setup atuin search
bindkey '^r' _atuin_search_widget

# Setup substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Setup mac-OS keyboard navigation (⌥ + ← / → and ⌘ + ← / →)
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# Enable Ctrl-x-e to edit command line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

### ----------------------------
### Misc
### ----------------------------

# Auto notify ignored commands
AUTO_NOTIFY_IGNORE+=("pnpm dev")
AUTO_NOTIFY_IGNORE+=("moon dev")
AUTO_NOTIFY_IGNORE+=("p dev")
AUTO_NOTIFY_IGNORE+=("opencode")

# Run opencode with required langfuse credentials
oc() {
  LANGFUSE_GATEWAY_KEY='op://mbspv5eykwvgtp5ohlcjkjfxv4/oeiaw3mjvvqpraft7szbwvshei/password' \
  LANGFUSE_USER_ID='op://mbspv5eykwvgtp5ohlcjkjfxv4/oeiaw3mjvvqpraft7szbwvshei/userid' \
  LANGFUSE_PUBLIC_KEY='op://mbspv5eykwvgtp5ohlcjkjfxv4/ahhudhblsqwsqcsho2xo3vveuq/public-key' \
  LANGFUSE_SECRET_KEY='op://mbspv5eykwvgtp5ohlcjkjfxv4/ahhudhblsqwsqcsho2xo3vveuq/secret-key' \
    op run --no-masking -- bash -c '
      set +x
      set -e
      : "${LANGFUSE_GATEWAY_KEY:?Missing gateway key}"
      : "${LANGFUSE_USER_ID:?Missing user ID}"
      : "${LANGFUSE_PUBLIC_KEY:?Missing Langfuse public key}"
      : "${LANGFUSE_SECRET_KEY:?Missing Langfuse secret key}"

      # Gateway
      opencode service set env LANGFUSE_GATEWAY_KEY "$LANGFUSE_GATEWAY_KEY"
      opencode service set env LF_USER_ID "$LANGFUSE_USER_ID"

      # Plugin
      opencode service set env LANGFUSE_USER_ID "$LANGFUSE_USER_ID"
      opencode service set env LANGFUSE_PUBLIC_KEY "$LANGFUSE_PUBLIC_KEY"
      opencode service set env LANGFUSE_SECRET_KEY "$LANGFUSE_SECRET_KEY"
      opencode service start

      exec opencode "$@"
    ' oc "$@"
}


# Eval trick to allow running command but not exiting afterwards
# https://superuser.com/a/230090
if [[ $1 == eval ]]
then
    "$@"
set --
fi
