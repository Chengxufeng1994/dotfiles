# 訊息格式規則

管的是**標題行與整體結構**。正文該寫什麼內容是 `rules/body-quality.md` 的職責，這份只管形狀。

## 格式

```
<type>[(<scope>)]: <description>

[optional body]
```

- **type** — 必填，限下表清單
- **scope** — 選填，描述變更區域的短名詞（`auth`、`api`、`db`、`cmd`）
- **description** — 必填，祈使句、小寫開頭、結尾不加句點
- **標題行 ≤72 字元**（type + scope + description 合計）
- **body** — 選填，與標題之間空一行

## Type 清單

| Type | 什麼時候用 |
|------|----------|
| `feat` | 新增功能或能力 |
| `fix` | 修正缺陷 |
| `refactor` | 既不加功能也不修缺陷的程式碼調整 |
| `docs` | 只動文件 |
| `test` | 新增或修正測試 |
| `chore` | 建置流程、工具、依賴更新 |
| `perf` | 效能改善 |
| `ci` | CI/CD 設定變更 |

**選不出 type 通常代表這個提交做了不只一件事**——回頭看 `rules/splitting.md` 的第一個拆分信號。

## Description 規則

- **祈使句**：`add login`，不是 `added login` 或 `adds login`
- **小寫開頭**
- **結尾不加句點**
- **≤72 字元**

祈使句不是格式潔癖：git 自己產生的訊息（`Merge branch...`、`Revert...`）就是祈使句，跟著寫才能讓 `git log` 讀起來像一串一致的指令，而不是一半命令一半日記。

## Scope 怎麼挑

**看 `git log` 的既有慣例，不要自己發明。** Step 1 已經跑過 `git log --oneline -10`，那份輸出就是答案——這個 repo 用的是模組名（`auth`、`api`）還是頂層目錄名（`claude`、`nvim`）？跟著它。

沒有既有慣例、且變更範圍明顯時才新增 scope。不確定就省略——scope 是選填的，錯的 scope 比沒有 scope 糟。

## 範例

```
feat: add user authentication
fix(api): handle empty response body
refactor(auth): simplify token validation logic
docs: update README with setup instructions
test(db): add integration tests for connection pool
chore: upgrade Go to 1.22
perf(cache): reduce allocations in hot path
ci: add race detector to test workflow
```

帶正文：

```
fix(auth): prevent token expiry race condition

WHAT: Serialize token validation and refresh behind a single mutex
WHY: Validation and refresh were not atomic, causing sporadic 401s
     under high concurrency (#2891)
HOW: Per-user mutex keeps unrelated users uncontended; existing tokens
     stay valid. Reproduced with a 200-goroutine test in auth_test.go.
```

壞範例與原因：

```
Fixed the bug               ← 缺 type，而且沒說哪個 bug
feat: Added login.          ← 過去式、結尾句點、大寫開頭
FEAT: add login             ← type 大寫
feat(very long scope): add  ← scope 應該是短名詞，不含空格
update stuff                ← 模糊，缺 type
```

## 驗證清單

檢查一則訊息（自己寫的或別人寫的）是否合格：

- [ ] 以合法 type 開頭（`feat`、`fix`、`refactor`、`docs`、`test`、`chore`、`perf`、`ci`）
- [ ] scope 若存在，是不含空格的小寫短名詞
- [ ] 格式恰好是 `type: description` 或 `type(scope): description`
- [ ] description 小寫開頭、結尾無句點
- [ ] 標題行 ≤72 字元
- [ ] 正文若存在，與標題之間空一行
- [ ] type 對得上實際變更（標 `fix` 的提交真的在修東西）

不合格時，**指出違反哪一條並直接給出修正版**，不要只說「格式不對」——使用者要的是能貼上去的東西。

最後一條最容易被漏掉，因為前六條都能機械檢查，只有它需要看 diff。type 標錯不會被任何 linter 抓到，但會讓自動產生的 changelog 把重構寫進 "Features"。
