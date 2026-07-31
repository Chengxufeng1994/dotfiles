---
name: resource-digest
description: 快速導讀任何資源 — 把 YouTube 影片、文章、論文、PDF、網頁或各種文檔一次性 digest 成結構化摘要（TL;DR、核心重點、大綱地圖、關鍵術語、如何應用）。當使用者說「幫我導讀」「導讀這篇」「這部影片講什麼」「幫我讀懂這篇」「這篇重點是什麼」「整理閱讀筆記」，或提供 URL、貼上文字、丟 PDF 並想快速理解時觸發。也涵蓋「讀這份資源前需要哪些背景」的深度導讀，以及輸出 Obsidian 筆記或簡報大綱。
---

# 快速導讀 (Resource Digest)

把任何資源一次性 **digest** 成一份結構化導讀。預設走快速路徑：**擷取內容 → 產出摘要**。使用者要更深入時才展開深度導讀。

## 步驟

### 1. 辨識來源並擷取內容

判斷資源型別（YouTube／網頁／文章／論文／PDF／文檔／已貼上的文字），依 [`references/acquisition.md`](references/acquisition.md) 取得乾淨的全文或字幕。

**完成條件**：手上有可讀的完整內容，且已知標題、作者／頻道、長度。若無法擷取（付費牆、需登入、掃描檔），停下並請使用者直接貼上內容再繼續。

### 2. 產出快速導讀

用 [`templates/digest.md`](templates/digest.md) 的結構，把來源填成一份導讀。

**完成條件**：模板每個區塊都由來源內容填滿、無留白；「大綱地圖」涵蓋來源**每個**主要段落／章節（影片用時間戳，文字用小標）；關鍵術語與金句直接出自來源，未杜撰。

### 3. 提供下一步（依需求）

產完摘要後，用一行提供選項，不主動展開：

- 「要更深入嗎？」→ 走 [`references/deep-reading.md`](references/deep-reading.md) 的讀前背景／批判思考／延伸閱讀
- 「要出 Obsidian 筆記嗎？」→ [`templates/obsidian-note.md`](templates/obsidian-note.md)
- 「要出簡報大綱嗎？」→ [`templates/slide-outline.md`](templates/slide-outline.md)

## 語言

預設 **繁體中文**。來源為英文時，專有名詞保留原文，其餘用中文解釋。
