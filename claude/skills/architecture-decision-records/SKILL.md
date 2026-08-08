---
name: architecture-decision-records
description: >
  把架構決策寫成 ADR（Architecture Decision Record）並維護決策紀錄：追問出真正評估過的替代方案與誠實的取捨，
  編號、寫入 docs/adr/、更新索引、處理 supersede 與狀態流轉；也用來回答「當初為什麼選 X」。
  觸發詞：「記成 ADR」「寫一份 ADR」「architecture decision record」「架構決策紀錄」「決策紀錄」
  「把這個決定記下來」「當初為什麼選 X」「為什麼不用 Y」「這個技術選型要留紀錄」「淘汰掉舊的決策」。
  English: write an ADR, record this decision, architecture decision record, document this
  technical choice, why did we choose X, supersede an ADR, decision log, technology selection record.
---

# Architecture Decision Records

程式碼會告訴未來的人**現在是什麼樣子**，卻永遠不會說**當初考慮過什麼、為什麼放棄**。ADR 補的就是這一段。

但多數 ADR 沒有做到這件事，因為它們是事後補的：決策早就做完了，寫的人回頭把「Alternatives Considered」填滿一些明顯較差的選項，讓紀錄看起來嚴謹。**一份被否決的方案如果你講不出支持它的最強論點，它就是稻草人**——那份 ADR 記錄的不是決策，是合理化。這份 skill 的重心因此不在模板，而在把真正的取捨問出來。

## 使用時機

- 剛做完技術選型、架構取捨，要把理由留下來
- 對話中已經在比較兩個方案並得出結論（本 SKILL 會提一句，不打斷）
- 有人問「當初為什麼選 X」「為什麼不用 Y」——讀既有 ADR 回答
- 舊決策要淘汰或被新決策取代，需要寫 supersede
- 專案要開始建立決策紀錄制度

## Skill Boundaries

- 決策**還沒做出來**、要探索開放式設計 → 改用 `system-design`（ADR 記錄的是已經收斂的結論）
- 功能規格、PRD、實作計畫 → 改用 `writing-a-spec` / `writing-a-plan`
- 淘汰的**執行**（遷移步驟、相容期、通知）→ 改用 `deprecation-and-migration`；ADR 只記「為什麼淘汰」
- 某個模式**怎麼實作** → 改用 `architecture-patterns` / `hexagonal-architecture`
- 本 SKILL 管 **決策這件事的紀錄**：值不值得記、內容誠不誠實、編號與索引、狀態流轉

## 流程

### 步驟一：確認決策值不值得記

先問一句：**這個決定，半年後有人想改的時候會需要知道理由嗎？**

不會，就別記。判準與分類表見 `rules/worth-recording.md`。

過度記錄跟不記錄一樣糟——一個塞滿瑣碎條目的 `docs/adr/` 會讓真正重要的三份沉下去。

### 步驟二：確認目錄狀態

```bash
ls docs/adr/ 2>/dev/null || echo "no adr dir"
```

已存在 → 讀 `README.md` 索引拿最大編號，並看一兩份既有 ADR **對齊這個專案實際的格式與語言**。既有慣例優先於本 SKILL 的模板。

不存在 → **先問使用者要不要建立**。得到同意才建 `docs/adr/`、`README.md`（索引表頭）與 `template.md`。沒得到同意就只把 ADR 內容輸出在對話裡。

### 步驟三：問出真正的取捨

這是本 SKILL 的重心，也是唯一不能省的一步。直接照著使用者說的寫，產出的是他已經知道的東西，沒有價值。

三件事要問到：

1. **真正評估過哪些方案**——包含當時看起來很有吸引力、最後沒選的那個
2. **每個被否決方案的最強論點**——講不出來就代表沒真的評估過
3. **這個決定會讓什麼變難**——只有好處的決策不存在

具體的提問法、怎麼分辨真評估與事後合理化、使用者答不出來時怎麼辦，見 `references/elicitation.md`。

### 步驟四：寫草稿

用 `templates/adr.md`。預設是精簡的四節（Context / Decision / Alternatives / Consequences），其餘章節依決策份量長出來——觸發條件在模板裡。

取代既有決策時改用 `templates/supersede.md`，它多了遷移計畫與 lessons learned 兩節。

編號取索引最大值 +1，補零到四位；檔名 `NNNN-短標題-用連字號.md`。

### 步驟五：交草稿，核可後才寫檔

把完整草稿貼在對話裡給使用者看過。**核可之前不寫任何檔案**——ADR 是會被別人引用的長期文件，寫錯比沒寫更難收拾。

使用者要改就改，要放棄就直接丟掉草稿，不留半成品檔案。

### 步驟六：寫檔並更新索引

寫 `docs/adr/NNNN-title.md`，然後把一列追加到 `docs/adr/README.md` 的索引表。

被取代的舊 ADR 要同時改狀態為 `superseded by ADR-NNNN` 並更新索引那一列。狀態流轉與索引格式見 `references/lifecycle.md`。

## 規則

- IMPORTANT：**每個被否決的方案都要通過稻草人測試。** 講得出支持它的最強論點嗎？講不出來就不要寫進去——列一個假選項比誠實地說「只認真評估過兩個」更糟。
- IMPORTANT：**Consequences 一定要有負面那半。** 只有好處的決策不存在；寫不出負面代價，代表取捨還沒想清楚，回步驟三。
- IMPORTANT：**記 why，不記 what。** 「我們用 Prisma」是 `package.json` 已經說過的話；「我們用 Prisma 而不是手寫 SQL，因為團隊只有一個人熟 SQL 而 schema 每週都在動」才是 ADR。
- IMPORTANT：**用現在式陳述。** 「We use X」而非「We will use X」——ADR 描述的是生效中的狀態，不是計畫。
- IMPORTANT：**兩分鐘要讀得完。** Context 超過十行就是太長了。ADR 的價值在被讀，不在完整。
- IMPORTANT：**語言跟隨專案。** `docs/adr/` 已有既有 ADR 就跟著它的語言與格式；沒有的話預設英文。本 SKILL 的對話用繁體中文。
- IMPORTANT：**主動偵測只提一句。** 察覺對話裡出現架構取捨並得出結論時，在該輪回覆末尾附一句「這看起來值得記成 ADR，要嗎？」就好。被忽略就算了，不要再提第二次，也不要自己開始寫。
- NEVER：**未經同意不可建立目錄或寫入檔案**，包含 `docs/adr/`、`README.md`、`template.md`。
- NEVER：**不可修改已經 accepted 的 ADR 的決策內容。** 決策變了就寫一份新的來 supersede 它——改寫舊紀錄會讓決策史消失，而決策史正是 ADR 存在的理由。修正錯字、補連結不在此限。
- NEVER：**不可編造沒發生過的評估。** 使用者說不出替代方案時就去問，或誠實寫「只評估過這一個，因為 X」。編出來的比較會被後人當真，並用來論證錯誤的結論。
- NEVER：**不可記瑣碎決策**（變數命名、格式化、次版本升級）。

### 邊界情況

- **補記一個很久以前的決策** → 照記，但在 Status 下標 `Date: YYYY-MM-DD (backfilled YYYY-MM-DD)`，並在 Context 開頭說明是回溯記錄。假裝它是當時寫的會讓時間線失真
- **決策還在討論中** → Status 用 `proposed`，正常寫進 `docs/adr/`。proposed 狀態存在的意義就是讓討論有個可引用的對象
- **使用者問「當初為什麼選 X」** → 不走流程。讀 `docs/adr/README.md` 索引找相關條目，讀出 Context 與 Decision 回答。找不到就說沒有紀錄，並問要不要現在補一份
- **這個 repo 用 `adr-tools`**（有 `docs/adr/.adr-dir` 或 `Makefile` 有 adr target）→ 用它的指令產生骨架再填內容，不要手動建檔繞過工具
- **一次要記多個決策** → 一份 ADR 一個決策。彼此相關就在 Related Decisions 互相連結，不要合併成一份

## 資料夾結構

```
architecture-decision-records/
├── SKILL.md
├── templates/
│   ├── adr.md              # 步驟四，主模板與章節長出條件
│   └── supersede.md        # 步驟四，取代既有決策時
├── rules/
│   ├── worth-recording.md  # 步驟一，判斷值不值得記
│   └── quality-check.md    # 步驟四寫完自檢；或要 review 別人寫的 ADR
└── references/
    ├── elicitation.md      # 步驟三，怎麼問出真正的取捨（最重要的一份）
    └── lifecycle.md        # 步驟六，狀態流轉、supersede、索引維護
```
