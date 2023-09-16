#
# Unix
#
alias l='ls -1A'         # lists files/directories
alias ll='ls -lah'         # lists files/directories with additional information
alias ln= "ln -v"
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
alias kgcrd="kubectl get crd"
alias kgn="kubectl get namespace"
alias kgs="kubetcl get service"
alias kgd="kubetl get deployment"
alias kgp="kubectl get pod"
alias kd="kubectl delete"
alias kdn="kubectl delete namespace"
alias kdd="kubectl delete deployment"
alias kdp="kubectl delete pod"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"
alias kdesc="kubectl describe"
alias klog="kubectl logs"
alias kexec='kubectl exec'
alias ktop="kubectl top"
alias krollout="kubectl rollout"

alias kctx="kubectx"
alias kns="kubens"