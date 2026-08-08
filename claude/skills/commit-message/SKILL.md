---
name: commit-message
description: >
  Git 提交流程助手：從髒工作區走到一組乾淨的原子提交——偵測並執行 pre-commit 檢查、
  判斷變更該不該拆成多次提交、挑選檔案暫存、產出 WHAT/WHY/HOW 結構的英文提交訊息。
  也負責提交訊息的格式規範本身：type 清單、scope、72 字元上限，以及驗證別人寫的訊息。
  觸發詞：「commit」「幫我提交」「幫我 commit」「寫 commit message」「提交這些變更」
  「這些改動要怎麼拆」「幫我拆 commit」「整理提交」「commit 一下」
  「這個 commit 訊息可以嗎」「檢查 commit message」「commit 格式對不對」「commit 規範」。
  English: commit these changes, write a commit message, split this into commits,
  stage and commit, help me commit, atomic commits, conventional commit format,
  is this commit message ok, validate this commit message, commit convention.
---

# Git 提交流程

## Why：提交訊息是唯一會被未來讀到的變更說明

diff 永遠都在，所以提交訊息**重述 diff 等於零資訊量**。半年後有人 `git blame` 到這一行，他看得到改了什麼，看不到的是：當時為什麼非改不可、考慮過哪些替代方案、改完之後哪裡有風險。訊息的全部價值就在補上這三件事。

這推導出兩條貫穿整份流程的原則：

1. **一次提交只講一件事。** 訊息只能解釋一個決策；塞了三件事的提交，任何一句 WHY 都會變得含糊。拆分不是潔癖，是讓 WHY 寫得出來的前提。
2. **正文寫動機，不寫檔案清單。** 「修改了 auth.go 和 middleware.go」是 diff 已經說過的話。

## Skill Boundaries

本 skill 管 **提交訊息這個產物的全部**——標題格式、正文內容，以及從髒工作區走到提交的流程。標題與正文是同一則訊息的兩半，寫的時候永遠同時需要，拆成兩個 skill 只會每次多載入一份。

- **分支策略、merge/rebase、worktree、release tag** → 改用 `git-workflow` skill。
- **PR 標題與描述** → 改用 `pull-request-convention` skill。

## 語言

- 本 skill 的對話與說明用繁體中文。
- **產出的 commit message 一律用英文**，包含標題與 WHAT/WHY/HOW 正文。理由是提交訊息會進 changelog、被 `git log` grep、被跨團隊閱讀。

## 執行流程

### Step 1：收集工作區狀態

```bash
git branch --show-current      # 在哪個分支
git status --porcelain         # 全部變更，含未追蹤
git diff --cached --stat       # 已暫存的規模
git diff --stat                # 未暫存的規模
git log --oneline -10          # 這個 repo 實際的訊息慣例
```

最後一行不能省：**`git log` 是比任何規範文件更誠實的慣例來源**。這個 repo 實際在用的 type 與 scope 命名（是 `claude` 還是 `skills`？scope 有沒有在用？），看歷史比看規範準確。

需要看實際內容而不只是規模時，再跑不帶 `--stat` 的 `git diff` / `git diff --cached`。

這幾個指令彼此沒有依賴，同一輪一起發出即可；Step 2 的偵測指令也可以併進同一輪，省一次往返。

### Step 2：跑 pre-commit 檢查

偵測專案類型後跑對應的 lint / build 指令，細節見 `references/precommit-detection.md`。

**偵測不到就跳過，並明確告訴使用者跳過了**——安靜地不檢查，比不檢查更糟，因為使用者會以為檢查過了。

檢查失敗時停下來問：先修，還是照樣提交？不要自己決定。使用者說 `--no-verify` 或「跳過檢查」時直接進 Step 3。

> 絕不使用 `git commit --no-verify` 繞過 repo 自己的 git hook。使用者說的「跳過檢查」指的是本流程的 Step 2，不是 repo 的 hook。

### Step 3：判斷要不要拆

讀完 diff 後問一個問題：**這些變更能不能用一句 WHY 講完？**

不能，就要拆。判準與拆分後的暫存手法見 `rules/splitting.md`。

拆分是**建議而非強制**——提出拆法、說明理由，讓使用者決定。他可能有你不知道的理由要一次提交完。

### Step 4：清理，然後挑檔案暫存

暫存前掃一遍 diff，把不該進版本庫的東西挑掉：

- 除錯殘留（`console.log`、`debugger`、`fmt.Println`、`dbg!`、註解掉的舊實作）
- 這次改動產生的死碼與沒用到的 import
- 臨時識別名（`V2`、`TEMP`、`TEST`、`foo2`）
- 臨時測試檔、腳手架、隨手產生的筆記檔

**只清理你自己這次改動製造的東西。** 看到既有的死碼就提一句，不要順手刪——那會變成混在提交裡的第二件事，正是 Step 3 要避免的。沒把握的程式碼一律不動。

清完之後，暫存的原則是「只包含實現本需求所必需的變更」：

- 已經有暫存內容 → 尊重使用者的選擇，只提交已暫存的部分。
- 完全沒暫存 → 依 Step 3 的拆分結果分批 `git add`；不拆才用 `git add -A`。
- 純格式化、依賴升級、大規模重新命名 → 一律獨立提交，它們會淹沒真正的變更。

### Step 5：寫訊息

標題是 `<type>[(<scope>)]: <description>`，祈使句、小寫、≤72 字元。type 清單、scope 怎麼挑、驗證清單見 `rules/message-format.md`。

正文用 WHAT / WHY / HOW 三段，判準見下一節，可直接套用的骨架見 `templates/commit-body.md`。

**只有一行就講得完的變更不必硬寫正文。** typo 修正、版本號更新這類提交，`docs: fix typo in setup instructions` 就是完整的訊息——硬塞 WHY 只會產生「because it was a typo」這種噪音。正文是給「讀者看 diff 看不出動機」的變更用的。

### Step 6：提交

```bash
git commit -m "<title>" -m "WHAT: ...
WHY: ...
HOW: ..."
```

提交後跑 `git log -1 --stat` 確認訊息與實際變更相符。多次提交就重複 Step 4–6。

**不要自動 push。** 除非使用者明講。

## WHAT / WHY / HOW 的判準

每一段各堵住一種缺口，判斷寫得好不好的唯一標準是：**這句話有沒有講出 diff 講不出來的事？**

### WHAT — 做了什麼

一句祈使句，動詞 + 對象，不含實作細節。

- 好：`Replace session cookies with JWT in the auth middleware`
- 差：`Update auth.go and middleware.go` ← 這是檔案清單，diff 已經說過

判斷動作 —— **遮蔽測試**：把 diff 遮起來只讀 WHAT，看得出改了什麼嗎？

### WHY — 為什麼要改

業務目標、使用者需求、缺陷背景、架構權衡。可引用 issue 編號（`Fixes #1234`）。

- 好：`Mobile clients cannot persist cookies across app restarts, forcing users to re-login daily (#1234)`
- 差：`To improve the authentication system` ← 泛泛而談，等於沒寫

判斷動作 —— **刪除測試**：把 WHY 整段刪掉，讀者能不能從 diff 自己推出來？能的話，這段沒有存在價值。

WHY 是三段裡最常寫壞的一段，因為它是唯一**必須來自程式碼之外**的資訊。寫不出來時，通常代表你不知道使用者為什麼要做這個改動——**去問，不要編**。

### HOW — 怎麼做的

整體策略、相容性與依賴、驗證方式、風險提示、對使用者的影響。**不逐條列檔案**，diff 已經有細節了。

- 好：`Issue short-lived JWTs with a refresh endpoint; existing sessions stay valid until expiry. Covered by integration tests in auth_test.go. Clients must send Authorization headers after the 2.0 rollout.`
- 差：`Modified three files and added a new function` ← 把 diff 用文字重念一遍

判斷動作 —— **重複測試**：這行是不是只是 diff 的自然語言版本？是的話刪掉。

## 邊界情況

**使用者已經自己暫存好了** → 不要重新 `git add`，直接從 Step 3 判斷已暫存的內容是否單一主題。

**變更跨了 repo 的多個領域但邏輯上是一件事**（例如同一個重構同時動 API 與前端）→ 這是拆分判準的例外，一起提交，並在 HOW 裡說明為什麼不能分開。

**要修改上一筆提交** → 使用者說 `--amend` 或「改上一個 commit」時，先跑 `git log -1` 確認那筆還沒 push，push 過的提交改寫會影響其他人，要先問。

**使用者只要訊息不要提交** → 說「幫我寫個 commit message」而沒說「提交」時，只做 Step 1、3、5，把訊息給他，不執行 `git commit`。

**使用者要驗證一則現成的訊息**（「這個 commit 訊息可以嗎」、貼一段別人寫的訊息來問）→ 完全不走流程，直接讀 `rules/message-format.md` 的驗證清單逐條檢查。指出違反哪一條，並給出可直接貼上的修正版。看得到對應的 diff 時，順便檢查 type 標得對不對——這是唯一機械檢查不到的一條。

**要把一段提交歷史轉成給其他 AI 的上下文** → 見 `references/context-prompt.md`。這是選用產出，不在主流程裡。

## 資料夾結構

```
commit-message/
├── SKILL.md      # 你正在讀的：六步流程 + WHAT/WHY/HOW 判準
├── rules/        # 「該遵守什麼？」——拆分與正文品質判準
├── templates/    # 「成品長什麼樣？」——正文骨架
└── references/   # 「這種情況怎麼辦？」——偵測表與選用產出
```

流程本身只用得到 git 內建指令，所以沒有 `scripts/`——包裝一層腳本會讓人以為它蒐集完整了，反而擋住「還缺什麼就自己補一條指令」的判斷。

| 檔案 | 什麼時候讀 |
| --- | --- |
| `references/precommit-detection.md` | Step 2，判斷該跑什麼檢查指令 |
| `rules/splitting.md` | Step 3，變更看起來不只一件事時 |
| `rules/message-format.md` | Step 5 寫標題時；或使用者要驗證一則現成訊息時 |
| `templates/commit-body.md` | Step 5，寫正文時 |
| `rules/body-quality.md` | Step 5 寫完後自檢，或使用者對訊息品質不滿意時 |
| `references/context-prompt.md` | 只在使用者要把提交歷史轉成 AI 上下文時 |
