# ---- OS Detection ----
if [[ "$OSTYPE" == "darwin"* ]]; then
  export IS_MAC=1
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export IS_LINUX=1
fi

# Homebrew (OS-specific paths)
# 必須放在 .zprofile：macOS 的 /etc/zprofile 會跑 path_helper 依 /etc/paths
# 重建 PATH，把 /usr/bin 等系統路徑拉到最前面。放在 .zshenv 會早於它而被降級。
if [[ -n "$IS_MAC" ]] && [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -n "$IS_LINUX" ]] && [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
