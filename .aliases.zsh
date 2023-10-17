#
# Unix
#
alias l='ls -1A'         # lists files/directories
alias ll='ls -lah'         # lists files/directories with additional information
alias rmrf="rm -rf"
alias mkdir="mkdir -p"
alias fd="find . -type d -name"
alias ff="find . -type f -name"

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
alias kgs="kubetcl get service -o wide"
alias kgd="kubetl get deployment -o wide"
alias kgp="kubectl get pods -o wide"

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
