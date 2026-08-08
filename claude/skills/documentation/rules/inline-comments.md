# 註解

註解是「只寫程式碼說不出來的東西」在最小尺度上的版本。判準一樣，但誘惑更大——因為寫註解很便宜，所以最容易寫出零價值的那種。

## 該寫的四種

### 1. 為什麼是這個做法（而不是顯而易見的那個）

```go
// Retry on 429 only. The upstream returns 500 for malformed payloads too,
// and retrying those just burns quota until the rate limiter trips.
```

讀者看到 `if status == 429` 會想「為什麼不也重試 500」。這行註解回答了那個問題，而程式碼永遠回答不了。

### 2. 隱含的假設與前置條件

```python
# Caller must hold the account lock. Verified by the integration tests in
# test_concurrent_transfer.py, not by anything here.
```

**「不是由這裡保證的」這種話特別有價值**——它告訴讀者去哪找那個保證，也警告他不要以為改這裡就安全。

### 3. 踩過的坑

```ts
// Safari fires `visibilitychange` twice on tab restore (WebKit #241485).
// Debouncing here rather than at the call site because two other listeners
// have the same problem.
```

這類註解省下的是**別人重新 debug 一次的時間**。它推不出來、查不到、只有踩過的人知道。附上 issue 連結讓後人能確認它是否已修復。

### 4. 反直覺的正確性

```rust
// Intentionally not `?`. A missing cache entry is normal on cold start;
// propagating it would turn every deploy into an incident.
```

看起來像 bug 但其實是刻意的地方，一定要註解。否則遲早有人「順手修好它」。

## 不該寫的四種

| 反模式 | 例子 | 為什麼 |
| --- | --- | --- |
| **複述程式碼** | `// increment count` 配 `count++` | 零資訊量，而且改名之後就變錯 |
| **重述型別** | 逐個參數寫「@param userId 使用者 ID」 | 型別已經說了，這只是把它抄一次 |
| **被註解掉的舊程式碼** | `// const old = ...` | 版本控制記得住。留著只會讓人不敢刪 |
| **過期的 TODO** | `// TODO: fix before launch`（三年前） | 沒有人負責的 TODO 是噪音。有意義的 TODO 要有 issue 編號 |

第二項在有型別系統的語言裡特別浪費。**`func Transfer(from AccountID, to AccountID, amount Money) error` 已經說完了所有參數的事**；值得註解的只有「from 和 to 不能相同，這裡不檢查，由 caller 保證」這種型別表達不了的約束。

## 判斷方法

寫註解前問：**這行如果刪掉，讀者會不會誤解這段程式碼？**

- 會誤解 → 寫
- 不會，只是讀得慢一點 → **先試著改程式碼**：改個好名字、抽個函式、加個具名常數。註解解決不了的可讀性問題，重構通常可以
- 完全不會 → 不要寫

中間那條是關鍵：**註解是最後手段，不是第一手段。** 一段需要三行註解才看得懂的函式，通常是在告訴你它該被拆開。用註解遮住設計問題，等於把問題留給每一個未來的讀者。

## 文件註解（docstring / godoc / JSDoc）

公開 API 的文件註解適用不同的標準——它們**會被生成成文件、被 IDE 顯示**，所以是 API 文件的一部分而不是給讀原始碼的人看的。

值得寫的：

- 這個函式在什麼情境下該被呼叫（型別說不出來）
- 錯誤情況：什麼時候回錯誤、回哪一種
- 副作用：會不會寫檔、發網路請求、改全域狀態
- 一個可執行的範例（能被 doctest 跑到最好）

不值得寫的：逐個參數重述型別、把函式名用句子重講一次（`// GetUser gets a user.`）。

## 註解的維護

**改程式碼時，同一個增量裡改掉受影響的註解。** 留到最後補一定會漏，因為那時你已經忘記哪些描述失效了。

看到明顯過期的註解就刪掉——那不算「順手修東西」，因為刪掉一個說謊的註解不會改變任何行為，而留著它會讓下一個讀者做出錯誤判斷。
