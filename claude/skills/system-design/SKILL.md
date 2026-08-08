---
name: system-design
description: >
  透過結構化的六步驟推理迴圈，引導開放式的系統／服務／架構設計討論——釐清需求、預估規模、提出 high-level 設計、評估 trade-offs、壓力測試故障模式、並針對最脆弱的部分 iterate。
  觸發詞：「設計一個系統」「設計一個限流器」「這個系統要怎麼設計」「怎麼估算容量/QPS」「幫我評估一下這個架構」「系統設計面試」「怎麼把這個服務撐到 10 倍流量」。
  English: design a system or service, how should we architect X, system design interview, scale this to Nx users, choosing between SQL/NoSQL, sizing a cache or queue, finding single points of failure in an existing design.
---

# System Design

**核心原則**：不要背誦架構，要從限制條件推理。「一個 URL shortener」或「一個聊天系統」沒有單一正確答案——對的答案取決於你講清楚的規模、一致性、成本限制。把每個設計都當成一個**假設**，直到某個限制條件改變（「如果寫入量變 10 倍呢？」「如果掉了一個 region 呢？」）就要冷靜重畫。一個只在你舉的那個例子上成立的設計，是背出來的，不是推理出來的。

## 使用時機

- 從零設計新系統／服務（例如「設計一個限流器」「設計一個通知系統」）
- 檢視或批判既有／提案中的架構，找出漏洞、SPOF、或擴展上限
- 選元件之前先估算容量——QPS、儲存、頻寬
- 在架構選項之間做決策（SQL vs NoSQL、monolith vs microservices、sync vs async、快取策略、shard key）
- 練習或進行系統設計面試

## Skill Boundaries

- 只有單一合理答案的窄範圍實作問題（例如「這段 query 要怎麼分頁」）不算開放式設計問題，直接回答即可，不需要走完整六步迴圈——把推理迴圈留給真正開放的設計問題

## 步驟一：釐清需求

把模糊的 prompt 轉成 functional requirements、non-functional constraints（latency、availability、consistency）、以及明確的 *out of scope*。把範圍收斂到幾個核心功能並講出來——想涵蓋所有東西的設計，通常什麼都做不好。不要默默選一個會實質改變設計的假設——問。

## 步驟二：預估規模

Back-of-the-envelope 估算 QPS、儲存、頻寬、讀寫比。決定設計的是數字，不是「流量很大」這種說法。估算工具箱（2 的冪次、延遲數字、QPS/儲存公式）見 `references/estimation-and-building-blocks.md`。

## 步驟三：提出 High-Level 設計

畫出方框與箭頭——clients、load balancer、services、資料儲存、快取、queue——加上核心 API contract（endpoint、request、response、primary key）。如果寫不出具體的 request/response 形狀，這張圖還只是猜測。先取得共識再往下深挖。Load balancer／快取／queue／CDN 的選型工具箱見 `references/estimation-and-building-blocks.md`；如果問題像是某個已知模式，見 `references/common-designs.md`。

## 步驟四：評估 Trade-offs

每個主要元件選擇都要講三件事：解決了什麼、讓什麼變差、什麼情況下會改變這個選擇。「這是業界標準」不算理由。這也是 `references/data-storage.md` 派上用場的地方——SQL vs NoSQL、replication、sharding 都是重 trade-off 的決策，不是預設值。

## 步驟五：壓力測試故障模式

假設每個元件都會壞。找出單點故障（SPOF），決定降級劇本（快取掛了使用者看到什麼？queue 塞車了呢？某個 region 斷線呢？），並規劃復原方式。「多加 retry」常常只是放大一場故障——先確認自己不是在製造一場 retry storm。

## 步驟六：Iterate / Deep-dive

從步驟五挑出最脆弱或最有趣的元件深入，或讓新的限制條件（「現在要撐 100 倍寫入」「現在要多 region」）驅動對應部分的重新設計。在新限制下重新設計，比死守原本的圖更能證明你真的理解——不要為了保住已經畫出來的圖而辯護。

> 這六步是一個**迴圈**，不是 checklist——把它當對話**講出來**：提出、邀請質疑、隨時調整。後面的步驟常常會把你送回前面的步驟，這正是重點，不是規劃失敗。不要默默選一個會實質改變設計的假設——不確定就問。

## Guardrails：設計是怎麼失敗的

這些是「訊號錯了」，不是「答案錯了」——留意自己有沒有做出這些動作：

| 錯誤 | 為什麼會出問題 | 怎麼修 |
|---|---|---|
| 先講架構再談需求 | 解決了錯的問題，範圍從沒被確認過 | 開頭先花點時間走完步驟一，再開始畫圖 |
| 沒有估算（只說「要能撐流量」） | Provisioning 會差好幾個數量級 | 選元件前先換算成 QPS/儲存/頻寬的數字 |
| 點名一個元件卻不解釋為什麼 | 「用 Kafka」不是設計，是用猜的 | 每個主要選擇都講 solves / worsens / when-to-change |
| 單點故障沒處理 | 一個元件掛掉整個系統就跟著掛 | 每層都要有備援：replica、multi-AZ、failover |
| 過早 sharding | 還沒到需要的時候就先付出巨大的維運複雜度 | 先垂直擴展、加 read replica，真的到頂了才 shard |
| 快取沒有失效策略 | 資料過期造成難以察覺的 bug | 一開始就定義 TTL 與失效方式（cache-aside、write-through），不要事後補 |
| 每條路徑都同步呼叫 | 一個慢依賴會把延遲串聯到所有呼叫者 | 不需要即時回應的路徑改用 queue；需要即時的路徑設 timeout |
| 把架構圖當成定案 | 一個小限制條件改變就整個設計崩潰 | 限制條件變了就重開步驟一到三，不要在原圖上硬補 |

## 收尾：Quick Diagnostic

設計討論收尾前跑一次這個檢查表，並把分數講出來——`score = round(通過項目 / 8 × 10)`。要講出哪一項最弱、怎麼補，不是只丟一個分數。

| 問題 | 答不出來代表什麼 |
|---|---|
| Functional / non-functional requirements 有寫下來嗎？ | 設計建立在沒講清楚的假設上 |
| 有 QPS／儲存／頻寬的估算嗎？ | 容量規劃只是用猜的 |
| 核心 API contract 具體嗎（request/response/primary key）？ | 這張圖還只是猜測 |
| 每個主要元件的 trade-off 都講清楚了嗎（solves/worsens/when-to-change）？ | 選擇是沒理由的預設值 |
| 每個元件都有備援，或者 SPOF 是被明確接受的嗎？ | 有靜悄悄的單點故障 |
| 資料擴展策略講清楚了嗎（垂直 → replica → sharding，含 shard key）？ | 成長到某個點就撞牆，卻沒有下一步 |
| 至少有一個故障模式的降級劇本嗎？ | 東西壞掉時，影響範圍是未知的 |
| 有沒有明講「這是隨著規模成長會重新考慮的地方」？ | 設計被當成定案，而不是一個假設 |

9-10 分＝幾乎每一項都有真實數字與明確 trade-off。5-6 分＝架構大方向對，但估算、備援、或故障劇本缺一塊。3 分以下＝架構在需求或估算都還沒出現前就先提出來了——回到步驟一。

## 參考檔案

| 檔案 | 什麼時候讀 |
|---|---|
| `references/estimation-and-building-blocks.md` | 估算規模（步驟二），或選擇 load balancer、快取層、CDN、message queue、consistent hashing（步驟三）時 |
| `references/data-storage.md` | 資料庫是瓶頸或是設計決策時——SQL vs NoSQL、replication topology、sharding 策略、denormalization（步驟三、四） |
| `references/common-designs.md` | 問題像是某個已知模式——URL shortener、rate limiter、news feed、chat、autocomplete、web crawler、unique ID generator——當作起手式去改，不是照抄 |
