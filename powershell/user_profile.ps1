Import-Module posh-git

oh-my-posh init pwsh | Invoke-Expression

# Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs 
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar 
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

Set-Alias -Name vim -Value nvim
Set-Alias sudo gsudo
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr

# OPENSPEC:START - OpenSpec completion (managed block, do not edit manually)
. "C:\Users\benny.xf.cheng\Documents\PowerShell\OpenSpecCompletion.ps1"
# OPENSPEC:END

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
