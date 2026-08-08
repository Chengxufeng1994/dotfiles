---
name: create-pull-request
description: >
  開 GitHub pull request 的完整流程：分析分支上所有變更、推送、產出符合規範的英文標題與正文，
  正文預設精簡、依 diff 內容長出 Security／Testing／Risks 章節。
  也負責 PR 標題與描述的格式規範本身：type 清單、scope、breaking change 標記、驗證清單。
  觸發詞：「開 PR」「幫我開 pull request」「建立 PR」「送 PR」「發 PR」「提 PR」
  「幫我寫 PR 描述」「這個 PR 標題可以嗎」「檢查 PR 格式」「PR 規範」。
  English: open a pull request, create a PR, draft a PR description, write a PR body,
  is this PR title ok, validate this PR title, PR convention, submit a pull request.
---

# 開 Pull Request

PR 描述的讀者不是未來的維護者，是**現在就要決定按不按 approve 的人**。他手上已經有完整 diff，缺的是判斷依據：這改動值不值得、風險在哪、哪裡要多看兩眼。所以 PR 描述最典型的失敗就是把 diff 用散文重念一遍——那對他是零資訊量。

## 使用時機

- 分支做完了要開 PR（新功能、修 bug、重構、文件更新）
- 只想要 PR 標題與描述的草稿，還不打算真的開
- 要驗證一個現成的 PR 標題或描述格式對不對
- 要 review 別人寫的 PR 描述夠不夠格

## Skill Boundaries

- PR 開出來之後的維護（同步新 commit、回覆 review comment、解衝突、rebase）→ 改用 `update-pr`
- 分支策略、merge/rebase、release tag → 改用 `git-workflow`
- commit 訊息的標題與 WHAT/WHY/HOW 正文 → 改用 `commit-message`
- 本 SKILL 管 **PR 這個產物的全部**：標題格式、正文內容與章節觸發條件、以及從分支到 PR 開出來的流程

## 流程

### 步驟一：收集分支狀態

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'   # base branch
git branch --show-current                                            # 目前分支
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null     # 有沒有 upstream
gh pr list --head "$(git branch --show-current)" --json number,url   # 是不是已經開過了
```

最後一條不能省：**分支上已經有 PR 時這個流程整個不適用**，改走 `update-pr`。`gh` 不會擋下重複開 PR，它會直接失敗或開出第二個。

### 步驟二：讀完整個分支會落地的變更

```bash
BASE=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
git log $BASE..HEAD --format="%h %s"
git diff $BASE...HEAD
```

三個點的 `$BASE...HEAD` 不是打錯：它比較分支點到 HEAD，排除 base 分支自己的新進展。用兩個點會把別人的 commit 也算進來。

讀的時候同時回答兩件事：

1. **這個分支的一句話理由是什麼？** 這會變成 Summary。
2. **哪些選用章節要長出來？** 對照 `templates/pr-body.md` 的觸發條件表。

### 步驟三：需要的話先推送

```bash
git push -u origin HEAD
```

步驟一顯示沒有 upstream 時才做。

### 步驟四：草擬標題與正文

**標題**是 `<type>(<scope>): <Summary>`，大寫開頭、結尾無句點。type 清單、breaking change 標記、驗證 regex 見 `rules/title-format.md`。

**正文**用 `templates/pr-body.md`。預設只有 Summary 與 Changes 兩節，其餘依觸發條件長出來。撰寫原則與自檢見 `rules/body-quality.md`。

分支上的 commit 如果照 `commit-message` 寫，正文的原料多半已經在裡面——PR 的 Summary 通常就是把各個 commit 的 WHY 收攏成一句，不必從 diff 重新推導。

### 步驟五：開 PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

回傳 PR URL。

## 規則

- IMPORTANT：**讀整個分支的 diff，不是只讀最新一筆 commit。** PR 是整個分支的產物，只看最後一筆會漏掉早期的決策，而那些通常才是 reviewer 最需要知道的。
- IMPORTANT：**heredoc 一定用 `<<'EOF'`（帶單引號）。** PR 正文幾乎一定含 markdown 反引號，少了單引號會被 shell 展開，送出去的描述就被竄改了。
- IMPORTANT：**章節有沒有要長出來，看 diff 不看 PR 大小。** 只改三行的 auth PR 需要 Security；改八百行的重新命名不需要。
- IMPORTANT：**產出的標題與正文一律用英文。** 它們會出現在 GitHub 列表、release note 與通知信裡。本 SKILL 的對話用繁體中文。
- NEVER：**不可寫「Neutral — no security-relevant changes」這種佔位內容。** 空章節不是中立的，它會讓下一個讀者以為安全性被評估過了——直接刪掉那一節。
- NEVER：**不可自動指派 reviewer 或要求 review**，除非使用者明講。
- NEVER：**不可在同一個分支開第二個 PR。** 回報既有 PR 的 URL，並說明該用 `update-pr`。
- NEVER：**why 寫不出來時不可自己編。** 先找 commit 訊息、關聯 issue、diff 裡的限制條件；都沒有就問使用者。編出來的動機會誤導 reviewer 把注意力放錯地方。

### 邊界情況

- **分支就是 base branch**（人在 `main` 上）→ 停下來說明沒東西可開，問要不要先開分支把 commit 搬過去
- **分支沒有 commit**（跟 base 一樣）→ 同樣停下來，不開空 PR
- **repo 有 `.github/PULL_REQUEST_TEMPLATE.md`** → 那是專案指定的格式，優先於本 SKILL 的模板；把內容填進它的章節，缺的依觸發條件補
- **使用者只要驗證現成的標題或描述** → 不走流程，直接用 `rules/title-format.md` 與 `rules/body-quality.md` 的驗證清單逐條檢查，指出違反哪一條並給出可直接貼上的修正版
- **使用者只要草稿不要真的開** → 只做步驟一、二、四，把標題與正文給他，不執行 `gh pr create`

## 資料夾結構

```
create-pull-request/
├── SKILL.md
├── rules/
│   ├── title-format.md    # 步驟四寫標題時；或要驗證現成標題時
│   └── body-quality.md    # 步驟四寫完自檢；或要 review 別人的描述時
└── templates/
    └── pr-body.md         # 步驟二判斷章節、步驟四寫正文時
```
