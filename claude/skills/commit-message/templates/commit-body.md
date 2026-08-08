# 提交訊息骨架

標題格式的規則不在這裡——見 `rules/message-format.md`。這份只管正文。

## 骨架

```
<type>[(<scope>)]: <description>

WHAT: <祈使句，動詞 + 對象，不含實作細節>
WHY: <業務目標 / 使用者需求 / 缺陷背景 / 架構權衡；可加 issue 編號與一句摘要>
HOW: <整體策略、相容性影響、驗證方式、風險或後續動作>
```

三段標籤用 `WHAT:` / `WHY:` / `HOW:` 大寫加冒號。標籤本身是給人掃讀用的錨點，讓 `git log` 裡一眼能跳到想看的那段。

## 執行指令

```bash
git commit -m "<title>" -m "WHAT: ...
WHY: ...
HOW: ..."
```

第二個 `-m` 會自動與標題之間空一行，符合 git 的慣例。正文內的換行直接寫在同一個 `-m` 的引號裡。

正文含有反引號、`$`、`!` 等 shell 會展開的字元時，改用 heredoc 寫進暫存檔再提交，避免 shell 竄改內容：

```bash
git commit -F - <<'EOF'
<title>

WHAT: ...
WHY: ...
HOW: ...
EOF
```

`<<'EOF'` 的單引號是關鍵——沒有它，heredoc 內容仍會被展開。

## 完整範例

### 修 bug

```
fix(auth): prevent token refresh race condition

WHAT: Serialize token validation and refresh behind a single mutex
WHY: Validation and refresh were not atomic, so concurrent requests could
     both see an expired token and issue two refreshes, invalidating each
     other and returning sporadic 401s under load (#2891)
HOW: Wrap both operations in a per-user mutex rather than a global one, to
     keep unrelated users uncontended. Existing tokens stay valid; no
     migration needed. Reproduced with a 200-goroutine test in auth_test.go
     that failed reliably before and passes after.
```

### 新功能

```
feat(api): support cursor-based pagination on /events

WHAT: Add cursor pagination to the events endpoint
WHY: Offset pagination drifted when new events arrived mid-scan, so clients
     doing a full sync silently skipped records. Reported by two integrators
     this quarter (#3102)
HOW: Return an opaque cursor encoding the last event's (timestamp, id).
     The existing `?page=` parameter still works and is deprecated rather
     than removed, so current clients keep functioning until the 3.0 cut.
     Covered by integration tests including the concurrent-insert case.
```

### 重構

```
refactor(storage): extract retry logic into a shared helper

WHAT: Move the retry-with-backoff loop out of the three storage backends
WHY: The loop had been copy-pasted three times and had already drifted —
     S3 retried on 429 but GCS did not, which is why bulk uploads failed
     only on GCS
HOW: Single helper taking a predicate for which errors are retryable, so
     backend-specific behaviour stays explicit instead of being implied by
     the copy. No behaviour change intended for S3; GCS now retries on 429,
     which is the actual fix. Existing backend tests cover all three paths.
```

## 什麼時候不寫正文

一行就講完的變更不必硬寫。`docs: fix typo in setup instructions` 已經是完整訊息——硬加 WHY 只會產生 "because it was a typo" 這種噪音。

判準：**讀者看 diff 能不能自己推出動機？** 能，就不需要正文。

實務上這類提交包含：typo 修正、版本號更新、格式化、註解調整、明顯的死碼刪除。

## 換行寬度

正文每行約 72 字元內折行。這不是美觀問題——`git log` 預設縮排 4 格顯示正文，超過 80 字元的行在標準終端機裡會被硬折，讀起來會斷在奇怪的地方。

延續行對齊標籤後方（如上面範例），讓三段的視覺邊界維持清楚。
