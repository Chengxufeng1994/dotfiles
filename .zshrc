# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/bennycheng/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

export HISTFILE=~/.zsh_history
export HISTSIZE=200000                 # huge internal buffer
export SAVEHIST=200000                 # huge history file

# 歷史記錄設定
setopt append_history           # 將歷史追加到檔案而非覆蓋
setopt inc_append_history       # 每次命令後立即寫入歷史
setopt extended_history         # 記錄時間戳記和執行時間
setopt hist_expire_dups_first   # 歷史滿時優先刪除重複項目
setopt hist_ignore_all_dups     # 忽略所有重複的歷史項目
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history            # 多個終端機共享歷史記錄

# 目錄導航
setopt auto_cd                  # 直接輸入目錄名稱即可切換
setopt auto_pushd               # cd 時自動將舊目錄推入堆疊
setopt pushd_ignore_dups        # 目錄堆疊中不重複儲存
setopt pushd_minus
setopt pushd_silent

# 其他便利設定
setopt no_beep                  # 關閉所有提示音
setopt interactive_comments     # 允許在互動模式使用 # 註解

# Job 控制設定
setopt hup
setopt long_list_jobs
setopt notify

# Shell 行為設定
setopt prompt_subst

unsetopt nomatch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# 補全系統進階設定
zstyle ':completion:*' rehash true                          # 自動偵測新安裝的命令
zstyle ':completion:*' menu select                          # 啟用互動式選單
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # 大小寫不敏感匹配

# 更完整的補全配置
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' use-cache on                     # 啟用補全快取
zstyle ':completion:*' cache-path ~/.zsh/cache          # 快取路徑
zstyle ':completion:*:match:*' original only            # 精確匹配優先
zstyle ':completion:*:approximate:*' max-errors 1 numeric  # 容許 1 個拼寫錯誤

# 補全選單美化
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # 使用 ls 顏色
zstyle ':completion:*' group-name ''                    # 補全項目分組
zstyle ':completion:*:descriptions' format '%B%d%b'     # 分組標題格式

# 特定命令的補全優化
zstyle ':completion:*:cd:*' ignore-parents parent pwd   # cd 時忽略當前目錄
zstyle ':completion:*:*:kill:*' menu yes select         # kill 命令使用選單
zstyle ':completion:*:kill:*' force-list always         # 總是顯示程序列表

zstyle :omz:plugins:ssh-agent identities id_rsa_github_personal id_rsa_github_vivotek id_rsa_gitlab_benny
zstyle :omz:plugins:ssh-agent lifetime 24h

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  autojump
  brew
  colored-man-pages
  docker
  docker-compose
  extract
  git
  kubectl
  ssh-agent
  z
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Easy way to check for command_existing in shell scripts
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# zsh plugins
# zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
export MAVEN_HOME=$HOME/Development/apache-maven-3.8.5
export PATH=$MAVEN_HOME/bin:$PATH

export POETRY_HOME=$HOME/.local
export PATH="$POETRY_HOME/bin:$PATH"

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

export CARGO_HOME=$HOME/.cargo/bin
export PATH=$CARGO_HOME:$PATH

export ISTIO_HOME=$HOME/Development/istio-1.15.3
export PATH=$ISTIO_HOME/bin:$PATH

# Added by Antigravity
export PATH="/Users/bennycheng/.antigravity/antigravity/bin:$PATH"

# 使用 fd 作為預設命令
export FZF_DEFAULT_COMMAND="fd --type f"

[ -f ~/.aliases.zsh ] && source ~/.aliases.zsh

# atuojump setup
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# fzf setup
[[ -s $(brew --prefix)/bin/fzf ]] && source <($(brew --prefix)/bin/fzf --zsh)

# >>>> pyenv(python version manager) (start)
if [ -x "$HOMEBREW_PREFIX/bin/pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"
fi
# >>>> pyenv(python version manager) (end)

# >>>> Kubectl command completion (start)
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
# <<<< Kubectl command completion (end)

# >>>> terraform (start)
if [ -f "$HOMEBREW_PREFIX/bin/terraform" ]; then
    complete -o nospace -C $HOMEBREW_PREFIX/bin/terraform terraform
fi
# >>>> terraform (end)

# >>>> Vagrant command completion (start)
if [ -f '/opt/vagrant/embedded/gems/gems/vagrant-2.3.7/contrib/bash/completion.sh' ]; then
    . '/opt/vagrant/embedded/gems/gems/vagrant-2.3.7/contrib/bash/completion.sh';
fi
# <<<<  Vagrant command completion (end)

# >>>> AWS command completion (start)
if [ -f '/usr/local/bin/aws_completer' ]; then
    complete -C  '/usr/local/bin/aws_completer' aws;
fi
# >>>> AWS command completion (end)

# >>>> GCP command completion (start)
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Development/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Development/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Development/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Development/google-cloud-sdk/completion.zsh.inc"; fi
# >>>> GCP command completion (end)

# starship setup
# eval "$(starship init zsh)"

# fnm setup
eval "$(fnm env --use-on-cd)"

# thefuch setup
eval $(thefuck --alias)

