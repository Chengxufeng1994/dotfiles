# PR 標題格式

## 格式

```
<type>(<scope>): <Summary starting with a capital letter, no trailing period>
```

- **type** — 必填，限下表
- **scope** — 選填，描述變更區域的短名詞（`auth`、`api`、`alarm`、`cmd`）
- **summary** — 必填，**大寫開頭**、祈使句、**結尾不加句點**

> **PR 標題大寫開頭，commit 訊息小寫開頭。** 兩者刻意不同：PR 標題會出現在 GitHub 列表、release note、通知信裡，是給人看的；commit 標題活在 `git log` 裡，跟著 git 自己的祈使句慣例走。搞混不會壞掉，但會讓 PR 列表看起來參差不齊。

## Type 清單

| Type | 什麼時候用 |
| --- | --- |
| `feat` | 新功能或能力 |
| `fix` | 修正缺陷 |
| `perf` | 效能改善 |
| `refactor` | 不改行為的程式碼調整 |
| `test` | 新增或修正測試 |
| `docs` | 只動文件 |
| `chore` | 維運、依賴、工具 |
| `ci` | CI/CD 設定 |
| `build` | 建置系統變更 |
| `revert` | 回退先前的 commit 或 PR |

**破壞性變更**在冒號前加 `!`：`feat(api)!: Remove deprecated v1 alarm endpoints`

`!` 放在冒號前而不是 type 後——`feat!(api):` 是錯的，會讓解析 PR 標題的工具漏掉這個標記。

## 驗證 regex

```
^(feat|fix|perf|test|docs|refactor|build|ci|chore|revert)(\([a-zA-Z0-9 ]+\))?!?: [A-Z].+[^.]$
```

## Scope 怎麼挑

看這個 repo 既有 PR 的用法（`gh pr list --limit 20` 就看得到），不要自己發明。不確定就省略——scope 是選填的，錯的 scope 比沒有 scope 糟。

## 範例

好的標題：

```
feat(project): Add cloud-based camera support with bandwidth calculation
fix(auth): Resolve token refresh race condition on concurrent requests
refactor(alarm): Extract notification dispatch into domain service
chore: Upgrade Go to 1.25 and update dependencies
feat(api)!: Remove deprecated v1 alarm endpoints
revert(ci): Roll back race detector workflow
```

壞的標題與原因：

```
Added login                       ← 缺 type
feat: added login.                ← summary 小寫、結尾句點
FEAT: Add login                   ← type 大寫
feat(very long scope name): Add   ← scope 應該是短名詞、不含空格
update stuff                      ← 缺 type、模糊
fix: fix the bug                  ← 小寫，而且 summary 等於沒說
```

## 驗證清單

檢查一個 PR 標題是否合格：

- [ ] 以合法 type 開頭（`feat`、`fix`、`perf`、`refactor`、`test`、`docs`、`chore`、`ci`、`build`、`revert`）
- [ ] scope 若存在，是括號內不含空格的短名詞
- [ ] 破壞性變更的 `!` 在冒號前，不在 type 後
- [ ] 格式恰好是 `type: Summary` 或 `type(scope): Summary`（冒號後有一個空格）
- [ ] summary **大寫開頭**、**結尾無句點**
- [ ] 標題精簡（目標 ≤72 字元，但可讀性優先於嚴格長度）
- [ ] type 對得上實際變更

不合格時，**指出違反哪一條並直接給出修正版**，不要只說「格式不對」。

最後一條是唯一機械檢查不到的——regex 過得了不代表 type 標對了。把重構標成 `feat` 不會被任何工具抓到，但會污染自動產生的 release note。
