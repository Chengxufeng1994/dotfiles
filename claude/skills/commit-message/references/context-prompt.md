# 把提交歷史轉成 AI 上下文（選用）

**這不在主流程裡。** 只在使用者明確要求時讀這份，例如：「把這幾個 commit 整理成給 AI 的上下文」「產生 context prompt」「把提交歷史餵給另一個 AI」。

## 為什麼可行

主流程要求每個提交的正文寫成 WHAT / WHY / HOW。這個結構本來就是為了讓未來的讀者快速抓到變更的目標、動機與手段——而「未來的讀者」包含另一個要做 code review、技術債評估或文件撰寫的 AI。

所以這一步不是額外的產出流程，只是**格式轉換**：把已經寫好的正文抽出來重排。這也是它不該佔主流程一格的原因——沒有新的判斷發生。

前提是那些提交的正文真的有寫 WHAT/WHY/HOW。沒有的話這份文件幫不上忙，只能回頭讀 diff 重建。

## 產生方式

```bash
git log --format='%s%n%b%n---' <base>..HEAD
```

`<base>` 是分支起點或使用者指定的範圍。抽出每筆的三段，按時間順序編號重排。

## 輸出格式

```
<Context>
1. [WHAT] Serialize token validation and refresh behind a single mutex
   [WHY] Validation and refresh were not atomic, so concurrent requests
         could both see an expired token and issue two refreshes (#2891)
   [HOW] Per-user mutex rather than a global one; existing tokens stay
         valid; reproduced with a 200-goroutine test
2. [WHAT] Add cursor pagination to the events endpoint
   [WHY] Offset pagination drifted when new events arrived mid-scan, so
         full syncs silently skipped records (#3102)
   [HOW] Opaque cursor over (timestamp, id); `?page=` deprecated not
         removed; covered by concurrent-insert integration tests
</Context>
```

**只輸出這個區塊，不加說明、標題、code fence 或空行。** 這個產出的讀者是另一個模型，任何包裝都是它要先剝掉的雜訊。

編號按提交的時間順序，因為後面的提交常常預設前面的已經發生。

## 邊界情況

**範圍內有沒寫正文的提交**（typo 修正之類）→ 直接略過，不要為了湊數硬編 WHY。上下文的價值在準確，不在完整。

**範圍內有 revert 或 fixup** → 兩筆抵銷的提交一起略過，把它們列進去只會讓讀的模型以為那個改動還在。

**使用者要的是 PR 描述而不是 AI 上下文** → 改用 `create-pull-request` skill。兩者的讀者不同：PR 描述給人看，需要 summary 與 test plan；這份給模型看，需要的是壓縮過的因果鏈。
