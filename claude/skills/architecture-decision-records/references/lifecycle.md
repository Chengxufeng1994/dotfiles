# 狀態流轉與索引維護

## 狀態

```
proposed ──→ accepted ──→ deprecated
    │                └──→ superseded by ADR-NNNN
    └──→ rejected
```

| 狀態 | 意思 |
| --- | --- |
| `proposed` | 討論中，尚未定案。存在的意義是讓討論有個可引用的對象 |
| `accepted` | 生效中，正在被遵循 |
| `deprecated` | 不再適用，且沒有東西取代（功能移除、模組不存在了） |
| `superseded by ADR-NNNN` | 被新決策取代，一定要連到取代它的那份 |
| `rejected` | 評估過但沒有採納 |

**`rejected` 的 ADR 要留著。** 直覺會想刪掉，但被否決的方案是最有價值的紀錄之一——它讓下一個人不必重跑同一輪評估。留在原地，號碼不重用。

## 決策變更時的完整動作

不是只寫一份新的就好。三個地方要一起動，漏掉任何一個索引就會說謊：

1. 寫新 ADR（用 `templates/supersede.md`），Status 寫 `accepted (supersedes ADR-MMMM)`
2. 把舊 ADR 的 Status 改成 `superseded by ADR-NNNN` —— **只改狀態行**，不動 Context / Decision / Consequences
3. 更新 `docs/adr/README.md`：新增新的一列，並把舊的那列狀態改掉

第二步是唯一允許動已 accepted ADR 的情況。改掉它的 Context 或 Decision 等於竄改當時的判斷紀錄，而決策史正是 ADR 存在的理由——後人需要看到「當初這樣想，後來發現不對」，不是一份被修正成永遠正確的文件。

## 目錄結構

```
docs/
└── adr/
    ├── README.md                       ← 索引
    ├── template.md                     ← 給人手動用的空白模板
    ├── 0001-use-postgresql.md
    ├── 0002-prisma-for-data-access.md
    ├── 0003-mongodb-user-profiles.md   ← superseded by 0012
    └── 0012-move-profiles-to-postgres.md
```

檔名不隨狀態改變——`0003` 被取代之後檔名不動，只有內容裡的 Status 改。改檔名會讓所有既有連結失效。

## 索引格式

```markdown
# Architecture Decision Records

決策紀錄索引。新增 ADR 請複製 `template.md`，編號取本表最大值 +1。

| ADR | Title | Status | Date |
| --- | --- | --- | --- |
| [0001](0001-use-postgresql.md) | Use PostgreSQL as the primary datastore | accepted | 2026-01-10 |
| [0002](0002-prisma-for-data-access.md) | Use Prisma for database access | accepted | 2026-03-11 |
| [0003](0003-mongodb-user-profiles.md) | MongoDB for user profiles | superseded by [0012](0012-move-profiles-to-postgres.md) | 2025-06-15 |
| [0012](0012-move-profiles-to-postgres.md) | Move user profiles to PostgreSQL | accepted | 2026-04-20 |
```

依編號排序，不依日期——編號就是時間順序，兩種排法並存只會讓人困惑。Date 欄位是決策日期，不是檔案修改日期。

## 編號

取索引最大值 +1，補零到四位。號碼一旦寫出去就不重用，包含被 rejected 或撤回的。

多人同時開 ADR 會撞號。撞到時後 merge 的那份改號，並更新它的檔名與索引列——這也是為什麼 ADR 之間要用連結而不是純文字引用號碼。

## adr-tools

專案有 `docs/adr/.adr-dir`，或 `Makefile` / `package.json` 裡有 adr 相關指令時，代表它在用 [adr-tools](https://github.com/npryce/adr-tools)。**用它的指令產生骨架再填內容**，不要手動建檔繞過工具——工具會維護編號與索引，手動建的檔案它看不到。

```bash
adr new "Use Prisma for database access"      # 產生下一號的骨架
adr new -s 3 "Move user profiles to Postgres" # 取代 ADR-0003，自動改舊的狀態
adr generate toc > docs/adr/README.md          # 重建索引
```

注意 `adr new` 產生的骨架是工具自己的格式，跟本 SKILL 的模板不完全一樣。**跟著專案既有的格式走**——一致性比模板正確性重要。

## 回溯補記

補記一個很久以前的決策時：

```markdown
**Date**: 2024-08-03 (backfilled 2026-04-20)
```

並在 Context 第一句說明這是回溯記錄。假裝它是當時寫的會讓時間線失真——後人會以為這個決策當初就有完整評估，而實際上 Alternatives 是事後回想的。

回想不起來的部分照實寫 `backfilled; original alternatives not recorded`，不要用推測填空。
