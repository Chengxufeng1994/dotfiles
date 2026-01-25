# ---- OS Detection ----
if [[ "$OSTYPE" == "darwin"* ]]; then
  export IS_MAC=1
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export IS_LINUX=1
fi

# Editor
export EDITOR='nvim'
# System
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="/bin:$PATH"
export PATH="/usr/sbin:$PATH"
export PATH="/sbin:$PATH"

# Homebrew (OS-specific paths)
if [[ -n "$IS_MAC" ]] && [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -n "$IS_LINUX" ]] && [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
