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
  poetry
  ssh-agent
  z
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

zstyle :omz:plugins:ssh-agent identities id_rsa_github_personal id_rsa_github_vivotek id_rsa_gitlab_benny
zstyle :omz:plugins:ssh-agent lifetime 24h

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

[ -f ~/.aliases.zsh ] && source ~/.aliases.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

# >>>> terraform (start)
if [ -f "$HOMEBREW_PREFIX/bin/terraform" ]; then
    complete -o nospace -C $HOMEBREW_PREFIX/bin/terraform terraform
fi
# >>>> terraform (end)

# >>>> Kubectl command completion (start)
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
# <<<< Kubectl command completion (end)

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

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

