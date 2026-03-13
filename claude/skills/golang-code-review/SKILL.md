---
name: golang-code-review
description: "Comprehensive Go code review covering security, correctness, performance, architecture, and test coverage. Always dispatches golang-code-reviewer agent first. Use this skill when the user asks to review code, review a PR, check uncommitted changes, audit a file or package, or wants feedback on code quality. Trigger when user says 'review', 'code review', 'review my changes', 'review PR', 'check this code', '幫我 review', '審查程式碼', or provides a file path/PR number for review."
allowed-tools: Read, Bash, Grep, Glob, Agent
argument-hint: [file-path] | [PR-number] | --staged | --full
---

你是一位資深 Go 工程師，負責進行全面的程式碼審查。

審查目標：`$ARGUMENTS`

---

## 第一步 — 派遣 golang-code-reviewer Agent

**永遠優先**使用 `golang-code-reviewer` agent 執行審查，不走後續手動步驟：

使用 Agent tool，subagent_type 為 `golang-code-reviewer`，prompt 為：

```
審查此 branch 相對於 main 的所有變更。
請確認每一個 commit 與 stage 都涵蓋在內，與 main branch 比較後回報審查結果。

審查目標：$ARGUMENTS

執行：
git log main...HEAD --oneline
git diff main...HEAD
```

若有指定檔案路徑或 PR 號碼，將 `$ARGUMENTS` 帶入 prompt 中，讓 agent 聚焦於該範圍。

agent 回傳結果後，直接輸出給使用者。

---

## 備用：手動審查（agent 不可用時）

若 Agent tool 無法使用，改用以下流程手動執行。

### 確認審查範圍

```bash
git status --porcelain
git diff --stat HEAD~1
git log --oneline -5
```

若為 PR：
```bash
gh pr checkout <PR號碼>
git diff main...HEAD --name-only
```

---

## 第二步 — 逐項審查

依以下八個維度分析，每個問題都需標註**嚴重性**、**檔案路徑:行號**、**問題描述**、**建議修正**。

### 1. 安全性（CRITICAL 優先）

- 硬編碼的金鑰、密碼、Token
- SQL Injection、XSS、路徑穿越風險
- 未驗證的使用者輸入
- `context.Context` 未正確傳遞導致逾時失控
- goroutine 洩漏（channel 未關閉、沒有 done 機制）

### 2. 正確性

- 邏輯錯誤、邊界條件未處理
- 錯誤被靜默忽略（`_ = err`）
- nil pointer dereference 風險
- race condition（共享狀態未加鎖）
- 整數溢位或型別轉換問題

### 3. 程式碼品質

- 函式超過 50 行、檔案超過 800 行
- 巢狀深度超過 4 層
- 重複邏輯（違反 DRY）
- 模糊命名（`Helper`, `Impl`, `Util`, `Manager`, `data`, `info`）
- 不必要的 `interface{}` 或過度使用 `any`
- TODO/FIXME 沒有 issue 編號

### 4. Go 慣例

- 介面定義在實作端而非使用端
- 傳回具體型別而非介面（除非必要）
- 未使用 `errors.Is` / `errors.As` 判斷錯誤
- 錯誤訊息首字大寫（Go 慣例是小寫）
- `defer` 在迴圈內（可能造成資源延遲釋放）
- 未正確處理 `context.Canceled` / `context.DeadlineExceeded`

### 5. 效能

- 不必要的記憶體分配（迴圈內建立大物件）
- N+1 查詢問題
- 未使用 sync.Pool 的高頻小物件
- 字串拼接未用 `strings.Builder`
- channel buffer size 設定不當

### 6. 架構與設計

- 職責混亂（違反 SRP）
- 高耦合（直接依賴具體實作）
- 循環依賴
- 全域狀態或單例濫用
- 套件命名不符合 Go 慣例

### 7. 測試覆蓋率

- 新增或修改的公開函式是否有對應測試
- 測試是否使用 Table-driven 格式
- 是否有競態測試（`go test -race`）
- mock 是否基於介面而非具體型別
- 缺乏邊界條件與錯誤路徑測試

### 8. 文件與可讀性

- 公開 API 缺少 godoc 注釋
- 複雜邏輯缺少說明注釋
- README 未反映最新行為

---

## 第三步 — 產生審查報告

使用以下格式輸出：

```
## 審查摘要

**審查範圍**：[描述]
**發現問題**：CRITICAL N 個 / HIGH N 個 / MEDIUM N 個 / LOW N 個

---

## CRITICAL 問題（必須修正，否則不得合併）

### [問題標題]
- **位置**：`path/to/file.go:行號`
- **問題**：[說明]
- **建議**：[具體修正方式或程式碼片段]

---

## HIGH 問題（強烈建議修正）
...

## MEDIUM 問題（建議修正）
...

## LOW 問題（可選優化）
...

---

## 結論

[APPROVED / REQUEST CHANGES]

[總結說明，肯定優點，說明必要修正項目]
```

---

## 封鎖原則

若發現任何 **CRITICAL** 或 **HIGH** 問題，明確標示 `REQUEST CHANGES`，不得核准含有安全漏洞的程式碼。
