# PR 正文模板

只有一份模板。**預設是精簡的兩節，其他章節各自有明確的觸發條件才長出來。**

這個方向很重要。原本的做法是「先給你完整模板，把沒東西寫的章節刪掉」，實務上會失敗兩次：忙的時候懶得刪，於是留下一堆 `N/A`；真正該寫 Security 的時候反而因為模板是預設存在的，隨手填一句「Neutral」交差。**用「什麼情況下要長出這一節」來問，比用「這一節有沒有東西寫」來問準確得多**——前者看 diff，後者看心情。

## 骨架

```markdown
## Summary

<一到兩句：這個 PR 做什麼、為什麼現在做。>

## Changes

- <按關注點分組的重點，寫「為什麼這樣改」而不是逐檔覆述>
- ...
```

這兩節永遠都有。以下每一節只在觸發條件成立時才加。

## 各章節的觸發條件

| 章節 | 什麼時候長出來 |
| --- | --- |
| `## Security` | diff 碰到認證、授權、session、token、加密／雜湊／簽章，或新的使用者輸入入口 |
| `## Testing` | 行為有變。純 `docs`／`chore`／格式化的 PR 不需要 |
| `## Impact / Risks` | 有 migration、破壞性變更、效能敏感路徑，或 rollback 不是「revert 就好」 |
| `## Checklist` | 這個 repo 的 `.github/PULL_REQUEST_TEMPLATE.md` 有清單，或 reviewer 要求過 |
| `## Notes` | 有程式碼看不出來的權衡、已知限制或後續工作 |

判斷依據是 **diff，不是 PR 的體感大小**。一個只改三行的 auth PR 需要 Security，一個改八百行的重新命名不需要。

### 完整形態

```markdown
## Summary

<一到兩句。>

## Changes

- <分組重點>

## Security

- <這個改動緩解了什麼威脅，或引入了什麼新的攻擊面>

## Testing

- <新增／修改的單元測試涵蓋什麼>
- <整合／E2E 測試，如果有>
- <手動驗證步驟>

## Impact / Risks

- <破壞性變更、migration、效能回歸、rollback 方式>

## Checklist

- [ ] Unit tests added/updated
- [ ] Integration tests updated (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] Backward compatibility checked (or breaking change explicitly marked)
- [ ] Security implications reviewed

## Notes

<權衡、後續工作，或程式碼裡看不出來的脈絡。>
```

**`## Security` 底下寫「Neutral — no security-relevant changes」等於沒有這一節，直接刪掉。**同理，全部未勾的 Checklist 是噪音不是嚴謹。

有關聯的 issue 用 `closes #123` / `fixes #456` 連起來，merge 時 GitHub 會自動關閉。

## 送出

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

`<<'EOF'` 的單引號是關鍵——沒有它，正文裡的反引號、`$`、`!` 會被 shell 展開，PR 描述會被竄改。PR 正文幾乎一定含 markdown 的反引號，所以這裡不是「保險起見」，是必要的。

## 範例

### 日常變更（只有兩節）

```markdown
## Summary

Extract the retry-with-backoff loop that had been copy-pasted across the three
storage backends. No behaviour change intended for S3 or Azure; GCS now retries
on 429, which is the actual bug this surfaced.

## Changes

- Single retry helper taking a predicate for which errors are retryable, so
  backend-specific behaviour stays explicit rather than implied by the copy
- GCS backend now passes 429 as retryable, matching S3 — this is why bulk
  uploads failed only on GCS (closes #412)
```

沒有 Testing 一節，因為既有的 backend 測試已經涵蓋三條路徑，沒有新增測試——**沒有東西可寫的時候不寫，比寫「Existing tests pass」誠實**。

### 高影響變更（長出 Security 與 Impact）

```markdown
## Summary

Replace session cookies with short-lived JWTs so mobile clients stop losing
their session on app restart (closes #1234).

## Changes

- Issue 15-minute access tokens with a refresh endpoint, rather than extending
  cookie lifetime — a long-lived cookie would have solved the symptom while
  widening the theft window
- Keep cookie auth working in parallel until the 3.0 cut, so existing web
  clients need no coordinated deploy

## Security

- Shortens the credential-theft window from 30 days (cookie lifetime) to 15
  minutes; refresh tokens are stored hashed and are single-use
- New attack surface: the refresh endpoint is unauthenticated by design and is
  rate-limited to 5 requests/minute per IP

## Testing

- Unit tests for token issue/verify/refresh including expiry boundaries
- Integration test for the concurrent-refresh race that broke the first attempt
- Manually verified on iOS that a cold start restores the session

## Impact / Risks

- No migration needed; existing sessions stay valid until they expire naturally
- Clients must send `Authorization` headers after the 3.0 rollout — the
  deprecation warning ships in 2.9 to give integrators one release of overlap
- Rollback is a straight revert; no schema or data changes
```
