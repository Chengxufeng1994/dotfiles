# ADR 主模板

Nygard 輕量格式為底。**預設是四節，其餘章節依決策份量長出來**——每一節都有明確的觸發條件。

這個方向很重要：先給完整模板再刪空章節，實務上會留下一堆「N/A」，而「Security: N/A」比沒有這一節更糟，它會讓後人以為安全性被評估過了。用「什麼情況要長出這一節」來問，答案來自決策本身，不來自寫的人有沒有力氣刪。

## 骨架

```markdown
# ADR-NNNN: [決策標題，用祈使或陳述句，不要用「關於 X 的討論」]

**Date**: YYYY-MM-DD
**Status**: proposed | accepted | deprecated | superseded by ADR-NNNN
**Deciders**: [誰參與了這個決定]

## Context

[2-5 句：什麼問題促成這個決定？當時有哪些限制條件？
 只寫決策當下成立的事實，不寫決策本身。超過十行就是太長。]

## Decision

[1-3 句：決定了什麼。用現在式——"We use X"，不是 "We will use X"。]

## Alternatives Considered

### [方案名稱]
- **Pros**: [這個方案最強的論點——講不出來就代表它是稻草人，整段刪掉]
- **Cons**: [具體的缺點，不是泛泛的「比較複雜」]
- **Why not**: [被否決的**具體**原因，要對應到 Context 裡的某個限制條件]

## Consequences

### Positive
- [這個決定讓什麼變簡單]

### Negative
- [這個決定讓什麼變難——這一段不能是空的]
```

## 各章節的長出條件

| 章節 | 什麼時候加 |
| --- | --- |
| `## Decision Drivers` | 有三個以上互相衝突的限制條件，需要先列清楚才看得懂為什麼這樣選 |
| `### Risks`（Consequences 內） | 存在「什麼情況下這個決定會失效」的已知條件 |
| `## Implementation Notes` | 有不寫下來就會被下一個人踩到的具體設定或約束 |
| `## Related Decisions` | 這份 ADR 依賴、補充或影響其他 ADR |
| `## References` | 有影響決策的外部依據（benchmark、文件、issue） |

判準是**這一節有沒有讀者需要而 Context/Decision 沒說到的資訊**，不是決策看起來重不重要。

## 完整範例

### 精簡形態（四節）

```markdown
# ADR-0007: Use Prisma for database access

**Date**: 2026-03-11
**Status**: accepted
**Deciders**: @benny, @lee

## Context

The schema is still changing weekly as the billing model settles, and every
change currently means hand-editing three query files plus a migration.
Only one person on the team is comfortable writing raw SQL, which makes
those edits a bottleneck and a review risk.

## Decision

We use Prisma as the data access layer for all new queries. Existing raw SQL
stays until the file it lives in is touched for another reason.

## Alternatives Considered

### sqlc
- **Pros**: Generates typed Go from plain SQL, so the SQL stays reviewable
  and there is no query-builder abstraction to fight when a query gets hairy
- **Cons**: Still requires everyone to write SQL; schema changes mean editing
  both the SQL and the migration
- **Why not**: Does not address the bottleneck — the constraint is SQL
  fluency on the team, and sqlc keeps SQL on the critical path

### Hand-written SQL with a thin wrapper
- **Pros**: Zero new dependencies, full control over every query, no ORM
  behaviour to learn or debug
- **Cons**: The status quo, which is what prompted this decision
- **Why not**: Does not change the weekly cost of schema churn

## Consequences

### Positive
- Schema changes are one edit plus a generated migration
- Types flow from the schema, so a renamed column breaks the build rather
  than production

### Negative
- Complex reporting queries will need `$queryRaw`, so we get an ORM *and*
  raw SQL rather than only one of them
- Prisma's connection pooling behaves differently under serverless; if we
  move billing to Lambda this decision needs revisiting
```

注意 Alternatives 只有兩個而不是三個——因為只認真評估過兩個。第二個方案的 Pros 寫的是真實的優點（零依賴、完全控制），不是為了襯托而寫的弱點。

### 加上 Risks 與 Related Decisions

```markdown
# ADR-0012: Store audit events in a separate append-only table

**Date**: 2026-04-02
**Status**: accepted
**Deciders**: @benny

## Context

Compliance requires a five-year record of who changed what. Today the
information is spread across `updated_by` columns that get overwritten on
every write, so the history only ever holds the most recent change.

## Decision

We write every mutation to an append-only `audit_events` table in the same
transaction as the mutation itself.

## Alternatives Considered

### Full event sourcing for the affected aggregates
- **Pros**: The audit trail becomes the source of truth rather than a
  parallel record that can drift, and temporal queries come for free
- **Cons**: Rewrites the write path for four services; the team has no
  event-sourcing experience
- **Why not**: The compliance requirement is read-only history, which the
  append-only table satisfies at a fraction of the cost

### Change data capture off the WAL
- **Pros**: No application changes at all; the database emits the stream
- **Cons**: Records physical row changes, not business intent — "row updated"
  cannot answer "who approved this refund"
- **Why not**: Loses the semantic layer that compliance actually asks for

## Consequences

### Positive
- Audit writes share the mutation's transaction, so the trail cannot silently
  fall behind
- No new infrastructure

### Negative
- Every write path grows a second insert; write latency rises measurably on
  the hot endpoints
- The table grows without bound and needs a partitioning plan before year two

### Risks
- Sharing a transaction means an audit-table problem takes writes down with
  it. Mitigation: the table has no foreign keys, no triggers, and no indexes
  beyond the primary key, so there is very little that can fail.

## Related Decisions
- ADR-0007: Use Prisma for database access — audit inserts go through the
  same layer, which is why they are cheap to add uniformly
```

## 檔名與編號

```
docs/adr/NNNN-short-title-with-dashes.md
```

`NNNN` 補零到四位，取索引最大值 +1。標題用小寫連字號，跟 ADR 標題對得上但不必逐字相同。

編號一旦寫出去就不重用——被否決或撤回的 ADR 留在原地標 `rejected`，不要把號碼讓給下一份。
