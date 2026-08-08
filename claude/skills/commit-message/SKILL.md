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

diff 永遠都在，所以提交訊息**重述 diff 等於零資訊量**。半年後有人 `git blame` 到這一行，他看得到改了什麼，看不到的是：當時為什麼非改不可、考慮過哪些替代方案、改完之後哪裡有風險。訊息的全部價值就在補上這三件事。

## 使用時機

- 工作區有變更要提交
- 變更混雜，需要判斷該拆成幾筆提交、怎麼拆
- 只想要 commit message 草稿，還不打算真的提交
- 要驗證一則現成的 commit 訊息格式對不對
- 要把一段提交歷史轉成給其他 AI 的上下文

## Skill Boundaries

- 分支策略、merge/rebase、worktree、release tag → 改用 `git-workflow`
- PR 標題與描述、開 PR → 改用 `create-pull-request`
- 本 SKILL 管 **提交訊息這個產物的全部**：標題格式、正文內容，以及從髒工作區走到提交的流程。標題與正文是同一則訊息的兩半，寫的時候永遠同時需要

## 流程

### 步驟一：收集工作區狀態

```bash
git branch --show-current      # 在哪個分支
git status --porcelain         # 全部變更，含未追蹤
git diff --cached --stat       # 已暫存的規模
git diff --stat                # 未暫存的規模
git log --oneline -10          # 這個 repo 實際的訊息慣例
```

最後一行不能省：**`git log` 是比任何規範文件更誠實的慣例來源**。這個 repo 實際在用的 type 與 scope 命名（是 `claude` 還是 `skills`？scope 有沒有在用？），看歷史比看規範準確。

需要看實際內容而不只是規模時，再跑不帶 `--stat` 的 `git diff` / `git diff --cached`。這幾條彼此沒有依賴，同一輪一起發出即可；步驟二的偵測指令也可以併進同一輪。

### 步驟二：跑 pre-commit 檢查

偵測專案類型後跑對應的 lint / build 指令，偵測順序與各語言指令見 `references/precommit-detection.md`。

檢查失敗時停下來問：先修，還是照樣提交？不要自己決定。

### 步驟三：判斷要不要拆

讀完 diff 後問一個問題：**這些變更能不能用一句 WHY 講完？**

不能，就要拆。五個拆分信號、三種不該拆的情況、拆分後的暫存手法見 `rules/splitting.md`。

拆分是**建議而非強制**——提出拆法（每筆的標題加對應檔案），說明理由，讓使用者決定。他可能有你不知道的理由要一次提交完。

### 步驟四：清理，然後挑檔案暫存

暫存前掃一遍 diff，把不該進版本庫的東西挑掉：除錯殘留（`console.log`、`debugger`、`fmt.Println`）、這次改動產生的死碼與沒用到的 import、臨時識別名（`V2`、`TEMP`、`TEST`）、臨時測試檔與腳手架。

清完之後：

- 已經有暫存內容 → 尊重使用者的選擇，只提交已暫存的部分
- 完全沒暫存 → 依步驟三的拆分結果分批 `git add`；不拆才用 `git add -A`
- 純格式化、依賴升級、大規模重新命名 → 一律獨立提交，它們會淹沒真正的變更

### 步驟五：寫訊息

**標題**是 `<type>[(<scope>)]: <description>`，祈使句、小寫、≤72 字元。type 清單、scope 怎麼挑、驗證清單見 `rules/message-format.md`。

**正文**用 WHAT / WHY / HOW 三段。三段各自要答什麼、好範例與判斷測試見 `rules/body-quality.md`；可直接套用的骨架與 heredoc 寫法見 `templates/commit-body.md`。

### 步驟六：提交

```bash
git commit -m "<title>" -m "WHAT: ...
WHY: ...
HOW: ..."
```

正文含反引號、`$`、`!` 等 shell 會展開的字元時改用 heredoc，寫法見 `templates/commit-body.md`。

提交後跑 `git log -1 --stat` 確認訊息與實際變更相符。多次提交就重複步驟四～六。

## 規則

- IMPORTANT：**WHAT 要通過遮蔽測試。** 遮住 diff 只讀 WHAT，看得出改了什麼嗎？寫成檔案清單或 `update`／`improve` 這種模糊動詞就是沒過。
- IMPORTANT：**WHY 要通過刪除測試。** 把 WHY 刪掉，讀者能從 diff 自己推出來嗎？能的話這段沒有存在價值。這是最常寫壞的一段，因為它是唯一必須來自程式碼之外的資訊。
- IMPORTANT：**HOW 要通過重複測試。** 這行是不是只是 diff 的自然語言版本？HOW 該講策略、相容性、驗證方式、風險，不是逐條列檔案。
- IMPORTANT：**產出的 commit message 一律用英文**（標題與正文），因為它會進 changelog、被 `git log` grep、被跨團隊閱讀。本 SKILL 的對話用繁體中文。
- IMPORTANT：**偵測不到 pre-commit 指令就跳過，並明確講出來。** 安靜地不檢查比不檢查更糟，使用者會以為檢查過了。
- IMPORTANT：**只清理自己這次改動製造的東西。** 看到既有的死碼提一句就好，順手刪會變成混在提交裡的第二件事。沒把握的程式碼一律不動。
- NEVER：**不可用 `git commit --no-verify` 繞過 repo 自己的 git hook。** 使用者說「跳過檢查」指的是步驟二，不是 repo 的 hook。
- NEVER：**不可自動 push**，除非使用者明講。
- NEVER：**WHY 寫不出來時不可自己編。** 那代表你不知道使用者為什麼要做這個改動——去問。但問之前先確認答案是不是已經躺在 repo 裡（關聯 issue、周邊程式碼、既有結構的空缺）。
- NEVER：**一行講得完的變更不可硬塞正文。** `docs: fix typo in setup instructions` 已經完整，加 WHY 只會產生「because it was a typo」這種噪音。

### 邊界情況

- **使用者已經自己暫存好了** → 不要重新 `git add`，直接從步驟三判斷已暫存的內容是否單一主題
- **變更跨多個領域但邏輯上是一件事**（同一個重構同時動 API 與前端）→ 拆分判準的例外，一起提交，並在 HOW 裡說明為什麼不能分開
- **要修改上一筆提交** → 先跑 `git branch -r --contains <sha>` 確認還沒 push；push 過的提交改寫會影響其他人，要先問
- **使用者只要訊息不要提交** → 只做步驟一、三、五，把訊息給他，不執行 `git commit`
- **使用者要驗證一則現成的訊息** → 不走流程，直接用 `rules/message-format.md` 的驗證清單逐條檢查，指出違反哪一條並給出可直接貼上的修正版。看得到對應 diff 時順便檢查 type 標得對不對——那是唯一機械檢查不到的一條
- **要把提交歷史轉成給其他 AI 的上下文** → 見 `references/context-prompt.md`，選用產出，不在主流程裡

## 資料夾結構

```
commit-message/
├── SKILL.md
├── rules/
│   ├── message-format.md        # 步驟五寫標題時；或要驗證現成訊息時
│   ├── splitting.md             # 步驟三，變更看起來不只一件事時
│   └── body-quality.md          # 步驟五寫正文與寫完自檢時
├── templates/
│   └── commit-body.md           # 步驟五、六，正文骨架與 heredoc 寫法
└── references/
    ├── precommit-detection.md   # 步驟二，判斷該跑什麼檢查指令
    └── context-prompt.md        # 只在要把提交歷史轉成 AI 上下文時
```

沒有 `scripts/`：流程只用得到 git 內建指令，包一層腳本會讓人以為它蒐集完整了，反而擋住「還缺什麼就自己補一條指令」的判斷。
