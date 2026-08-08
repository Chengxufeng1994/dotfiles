# Supersede ADR 模板

取代既有決策時用這份。它跟主模板的差別不只是多兩節——**取代型 ADR 的讀者問的是不同的問題**：不是「為什麼選這個」，而是「當初那個判斷錯在哪，這次憑什麼更好」。

## 骨架

```markdown
# ADR-NNNN: [新決策標題]

**Date**: YYYY-MM-DD
**Status**: accepted (supersedes ADR-MMMM)
**Deciders**: [誰]

## Context

[ADR-MMMM（年份）當時選了 X，理由是 A、B、C。從那之後有什麼改變：
 - 哪個當時的假設不成立了
 - 哪個當時不存在的限制出現了
 - 哪個當時的預期沒有實現]

## Decision

[1-3 句，現在式。]

## Alternatives Considered

### 維持現狀（不取代 ADR-MMMM）
- **Pros**: [不動的真實好處——零遷移成本、零風險。這一項一定要認真寫]
- **Cons**: [繼續承擔的代價]
- **Why not**: [為什麼現在值得付遷移成本]

### [其他方案]
- 同主模板

## Migration Plan

[分階段，每階段要有可觀察的完成條件。沒有遷移計畫的取代型 ADR 是空頭支票。]

1. **Phase 1**：[做什麼] — 完成條件：[怎麼知道做完了]
2. **Phase 2**：...

## Consequences

### Positive / ### Negative / ### Risks
[同主模板]

## Lessons Learned

[從 ADR-MMMM 這段經驗學到什麼，寫給未來做類似判斷的人。
 這一節是取代型 ADR 獨有的價值——它讓一個過時的決策變成可複用的經驗。]
```

## 三件容易做錯的事

**「維持現狀」必須是認真的選項。** 它有真實的優點：零遷移成本、零風險、團隊不用重新學。把它寫成稻草人（「Cons: 現狀不好」）等於承認這份 ADR 是來背書一個已經做完的決定，而不是記錄一次評估。遷移的代價通常被低估，而唯一會誠實提醒後人的地方就是這一節。

**Lessons Learned 不是檢討會。** 要寫的是可遷移的判斷，不是自責：

- 好：`Schema-flexibility benefits were overestimated because the schema stabilised within two quarters; weigh "we might need flexibility" arguments against how fast the domain is actually still moving.`
- 差：`We should have thought about this more carefully.`

判準：**這句話對一個做完全不同技術選型的人有沒有用？** 沒有的話就還沒寫到位。

**舊 ADR 要同步改。** 寫完新的之後，回去把 ADR-MMMM 的 Status 改成 `superseded by ADR-NNNN`，並更新索引那一列。這是唯一允許動已 accepted ADR 的情況——只改狀態行，不動它的 Context、Decision 或 Consequences。那些是當時的判斷紀錄，改掉就沒有決策史了。

## Deprecate 與 Supersede 的差別

- **deprecated**：這個決策不再適用，但沒有東西取代它（功能移除了、那個模組不存在了）。狀態改成 `deprecated`，不需要新的 ADR
- **superseded**：有新的決策接手。寫新 ADR，舊的標 `superseded by ADR-NNNN`

分不清時看有沒有「新的做法」。沒有就是 deprecated。
