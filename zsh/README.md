# zsh 設定分層說明

本目錄的三個設定檔各有明確職責。加新設定前先查這份文件,放錯層是本 repo 歷史上最常見的 bug 來源(PATH 被 path_helper 重排、HOMEBREW_PREFIX 未定義等)。

## 載入順序

zsh 依 shell 類型依序載入(系統檔 → 使用者檔交錯):

| 順序 | 檔案 | 何時執行 | 本 repo 的職責 |
|------|------|----------|----------------|
| 1 | `/etc/zshenv` → `~/.zshenv` | **每一個 zsh process**(含 script、非互動) | editor、locale 保底 |
| 2 | `/etc/zprofile` → `~/.zprofile` | **login shell** | brew shellenv、OS 偵測、系統級 PATH |
| 3 | `/etc/zshrc` → `~/.zshrc` | **互動 shell** | prompt / plugin / alias / completion / runtime hook |

- macOS 的終端機(Terminal.app、Ghostty、iTerm、tmux pane)預設開 **login + interactive** shell → 三個檔都會跑,順序 1→2→3。
- 在 shell 裡再打 `zsh` 開子 shell → 只跑 1 和 3,**跳過 `.zprofile`**。
- 跑 script(`zsh foo.sh`)→ 只跑 1。

## 各檔案放什麼

### `.zshenv` — 極簡,只放「每個 process 都需要」的

- ✅ `EDITOR` / `VISUAL`、`LANG` 保底(用 `${LANG:-...}` 避免覆蓋上游)
- ❌ **禁止動 PATH**:macOS 的 `/etc/zprofile` 會在它之後跑 `path_helper`,依 `/etc/paths` 重建 PATH,把你在這裡 prepend 的路徑降級到後面
- ❌ 不放任何慢的東西(eval、source)——script 執行也會付這筆成本

### `.zprofile` — login 時跑一次的環境建置

- ✅ OS 偵測(`IS_MAC` / `IS_LINUX`)
- ✅ `brew shellenv`(**必須在這層**:要排在 `/etc/zprofile` 的 path_helper 之後,PATH 才不會被重排降級;`HOMEBREW_PREFIX` 也在此定義,`.zshrc` 依賴它)
- ✅ 系統級、一次性的環境變數
- ❌ 不放 alias、prompt、completion——非互動的 login shell 用不到

### `.zshrc` — 互動 shell 專用

依檔內既有分區順序(**順序有意義,不要亂插**):

1. `typeset -U path`(子 shell 不繼承 typeset 屬性,需重宣告)
2. history / setopt / zstyle(completion 設定要在 compinit 之前)
3. plugin 變數設定(`ZSH_AUTOSUGGEST_*`、`YSU_*` 等)→ `plugins=()`
4. **fpath 追加**(homebrew site-functions、vagrant)——必須在下一步之前,compinit 才掃得到
5. `source $ZSH/oh-my-zsh.sh`(**compinit 在這裡面執行**)
6. bashcompinit(給 `complete -C` 型補全用,如 aws)
7. keybindings、使用者工具鏈 PATH prepend(Go / cargo / .local/bin)
8. prompt(oh-my-posh)與 runtime hook(fnm、zoxide、pyenv、fzf、thefuck)——需要 compinit 已完成的 eval 都放這區
9. 各工具補全(aws / gcp / terraform)
10. 最後 source `.aliases.zsh`(壓在最後,確保覆蓋 plugin 提供的 alias)

## 加新設定的決策表

| 要加的東西 | 放哪 |
|------------|------|
| 環境變數,script 也要用 | `.zshenv` |
| 環境變數,牽涉 PATH 或只有人用 | `.zprofile` |
| alias、函式、keybinding | `.zshrc`(alias 放 `.aliases.zsh`) |
| 工具的 `eval "$(xxx init zsh)"` | `.zshrc` runtime 區(oh-my-zsh 之後) |
| 補全檔目錄(fpath) | `.zshrc` 的 fpath 區(**oh-my-zsh 之前**) |
| 新 OMZ plugin | `plugins=()`;custom plugin 先裝到 `~/.oh-my-zsh/custom/plugins/` |

## 已知陷阱

- **path_helper**(macOS 限定):`/etc/zprofile` 會重建 PATH。所以「PATH 相關一律 `.zprofile` 以後,不進 `.zshenv`」。
- **`$HOMEBREW_PREFIX` 只在 login shell 保證存在**(由 `.zprofile` 定義)。`.zshrc` 多處引用它;Linux 終端機若開的是非 login shell,這些行會拿到空值——跨平台部署時要確認終端機的 login shell 設定。
- **fpath 必須在 compinit 前就緒**:補全檔加進 fpath 但放在 `source oh-my-zsh.sh` 之後 = 無效。
- **工具補全優先吃現成的**:brew formula 多半已附 `_xxx` 到 `site-functions`(已在 fpath),OMZ plugin 也常有背景快取。加 `source <(xxx completion zsh)` 前先確認不是重複——kubectl 曾因此每次啟動多付一次前景生成。
