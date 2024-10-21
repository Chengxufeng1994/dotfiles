#
# Unix
#
alias l='ls -l --color=auto'                # lists files/directories
alias ll='ls -alh --color=auto'             # lists files/directories with additional information
alias lh='ls -alths --color=auto'           # lists files/directories with additional information

# alias ls='exa'
# alias l='exa -lbF --git'
# alias ll='exa -lbGF --git'
# alias llm='exa -lbGd --git --sort=modified'
# alias la='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'
# alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'
# alias lS='exa -1'
# alias lt='exa --tree --level=2'

alias grep='grep --color=auto'
alias mygrep='grep -rnIi --color'
alias rmrf="rm -rf"
alias mkdir="mkdir -p"
alias tf="tail -f"

alias fd="find . -type d -name"
alias ff="find . -type f -name"

alias ports="netstat -tulanp"
alias ntlp="netstat -tlnp"

alias psgrep='ps -ef | grep '
alias psme='ps -ef | grep $USER --color=always'
#cpu rank
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
# memory rank
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

alias meminfo='free -h -l -t'
alias cpuinfo='lscpu'

alias duh='du -h'
alias duhs='du -h -s'
alias duhd='du -h -d 1'
alias ducks='du -cks * | sort -rn | head' 

#
# ripgrep
#
alias rgg='rg -tgo --no-ignore-vcs --hidden --column --line-number --no-heading --color=always --smart-case'
# alias rg='rg --files --no-ignore-vcs --hidden --column --line-number --no-heading --color=always --smart-case'

# 
# lazygit
alias lg='lazygit'

#
# Kubectl
# https://gist.github.com/zephinzer/f0a321e9bcb204debd45160b890eb6a3
#
alias k="kubectl"
alias kv="kubectl version"

alias kget="kubectl get"
alias kgall="kubectl get --all-namespaces"
alias kgw="kubectl get -o wide"
alias kgcrd="kubectl get crd"
alias kgn="kubectl get node -o wide"
alias kgns="kubectl get namespace -o wide"
alias kgs="kubectl get service -o wide"
alias kgsl="kubectl get service -o wide --show-labels"
alias kgd="kubectl get deployment -o wide"
alias kgp="kubectl get pods -o wide"
alias kgpl="kubectl get pods -o wide --show-labels"

alias kccm="kubectl create configmap"

alias kd="kubectl delete"
alias kdn="kubectl delete namespace"
alias kdd="kubectl delete deployment"
alias kdp="kubectl delete pod"

alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"

alias kdesc="kubectl describe"

alias klog="kubectl logs"                   # dump pod logs (stdout)
alias klogf="kubectl logs -f"               # stream pod logs (stdout)
# e.g: klog <pod> -c <container>

alias krit="kubectl run -i --tty"           # Run pod as interactive shell
# e.g: krit busybox --image=busybox:1.28 -- sh

alias keit='kubectl exec -it'               # Interactive shell access to a running pod
# e.g: keit --stdin --tty <pod> -- <command>

alias ktop="kubectl top"                    # show metrics for a given pod and its containers

alias kr="kubectl rollout"
alias krh="kubectl rollout history"
alias krs="kubectl rollout status -w" 
alias krr="kubectl rollout restart" 

alias kcv="kubectl config view"             # show Merged kubeconfig settings.
alias kcc="kubectl config current-context"  # display the current context
alias kcgc="kubectl config get-contexts"    # display list of contexts.

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace)
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

alias kctx="kubectx"
alias kns="kubens"
