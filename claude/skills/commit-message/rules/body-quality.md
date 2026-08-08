# 正文品質

## 三段各自要答什麼

每一段堵住一種缺口。判斷寫得好不好的唯一標準是：**這句話有沒有講出 diff 講不出來的事？**

### WHAT — 做了什麼

一句祈使句，動詞 + 對象，不含實作細節。

> `Replace session cookies with JWT in the auth middleware`

**遮蔽測試**：把 diff 遮起來只讀 WHAT，看得出改了什麼嗎？

### WHY — 為什麼要改

業務目標、使用者需求、缺陷背景、架構權衡。可引用 issue 編號。

> `Mobile clients cannot persist cookies across app restarts, forcing users to re-login daily (#1234)`

**刪除測試**：把 WHY 整段刪掉，讀者能不能從 diff 自己推出來？能的話這段沒有存在價值。

WHY 是三段裡最常寫壞的，因為它是唯一**必須來自程式碼之外**的資訊。

### HOW — 怎麼做的

整體策略、相容性與依賴、驗證方式、風險提示、對使用者的影響。**不逐條列檔案**，diff 已經有細節。

> `Issue short-lived JWTs with a refresh endpoint; existing sessions stay valid until expiry. Covered by integration tests in auth_test.go. Clients must send Authorization headers after the 2.0 rollout.`

**重複測試**：這行是不是只是 diff 的自然語言版本？是的話刪掉。

HOW 該答的四件事，按重要性排序：採用的整體策略（為什麼是這個做法）、相容性影響（舊資料／舊 client 會怎樣）、驗證方式（測試涵蓋到哪）、風險或後續動作。四項不必都寫，但**相容性與驗證方式是預設要有的**——這兩項是 diff 最不可能表達的資訊。

## 提交前的六項自檢

存在的理由是：**寫壞的正文通常不是漏了某一段，而是某一段寫了但沒有作用**——三段都在、格式正確、讀起來像模像樣，卻沒有任何一句是 diff 講不出來的。這種空轉從表面看不出來，只能用測試逼出來。

| 檢查項 | 判斷動作 | 沒過的症狀 |
|---|---|---|
| WHAT 可獨立閱讀 | 遮蔽測試 | 寫成檔案清單或模糊動詞（update、improve、adjust） |
| WHY 有資訊量 | 刪除測試 | 泛泛而談，或只是 WHAT 的改寫 |
| HOW 不重複 diff | 重複測試 | 出現「新增了 X 函式」「修改了三個檔案」 |
| 三段不互相複述 | **主詞測試**：WHAT 的主詞是動作，WHY 是問題或需求，HOW 是策略 | 三段講同一件事，只是換句話說 |
| 標題與正文一致 | **對照測試**：標題的 type/scope 對得上 WHAT 描述的動作嗎？ | 標題寫 `fix`，WHAT 描述的其實是新功能 |
| 訊息與 diff 相符 | **驗收測試**：跑 `git diff --cached --stat`，訊息涵蓋所有變更嗎？ | 暫存區裡有訊息沒提到的檔案 |

最後一項不能省。訊息與實際提交內容不符是最難事後發現的錯誤——它不會讓任何東西壞掉，只會在半年後誤導某個人。

## 反模式速查

### WHAT

| 反模式 | 為什麼壞 |
|---|---|
| `Update auth.go and middleware.go` | 檔案清單，diff 已經有 |
| `Fix bug` | 沒說哪個 bug |
| `Improve performance` | 動詞模糊，沒有對象 |
| `Refactor code for better readability` | 通用到能貼在任何提交上 |

**測試**：這句 WHAT 能不能原封不動貼到另一個提交上？能的話它沒說出任何事。

### WHY

| 反模式 | 為什麼壞 |
|---|---|
| `To improve the authentication system` | 泛泛而談，過不了刪除測試 |
| `Because the old code was messy` | 主觀評價，不是動機 |
| `Requested by the team` | 沒說為什麼要求 |
| `See #1234` | 只給編號不給脈絡 |

引用 issue 要**編號加一句摘要**：`Mobile clients lose sessions on app restart (#1234)`。issue tracker 會遷移、會關閉、會權限變更，git history 不會。

### HOW

| 反模式 | 為什麼壞 |
|---|---|
| `Added a new function in utils.go` | 重述 diff |
| `Changed the logic` | 沒說改成什麼策略 |
| 逐條列出每個檔案改了什麼 | diff 的職責，而且會過期 |
| 完全省略驗證方式 | 讀者無法判斷這個改動被驗證到什麼程度 |

## 誠實原則

自檢的全部價值在於它會誠實指出弱點。六項全過而且找不到任何可改的地方時，先懷疑自己在敷衍——尤其是 WHY 的刪除測試，它的通過率在實務上遠低於直覺。

某一項確實沒過但使用者接受（例如他就是不想說明動機），照他的意思提交，但要明講你跳過了哪一項，不要安靜地放過。
