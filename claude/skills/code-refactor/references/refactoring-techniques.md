# 重構技法目錄

壞味道說「哪裡不對」（`rules/diagnosis.md`），設計模式說「目標架構長怎樣」（`rules/pattern-selection.md`）。這份是中間那層：**從這裡到那裡的每一個機械動作叫什麼名字**。

用具名技法而不是「我把它改乾淨一點」有兩個實際好處：每個技法都有已知的安全操作序列，而且多數 IDE 有自動化版本——自動的比手改安全，因為它會處理你會忘記的呼叫端。

## 拆解類

| 技法 | 什麼時候用 | 動作 |
| --- | --- | --- |
| **Extract Function/Method** | 函式要捲畫面、或需要註解分段 | 把一段連續邏輯抽成有名字的函式。**註解分段的位置通常就是切點**——那句註解會變成函式名 |
| **Extract Class/Component** | 一個型別有兩組不相干的欄位與方法 | 把其中一組搬到新型別，原型別持有它 |
| **Extract Variable** | 表達式複雜到看不懂 | 抽成有語意的具名變數，名字取代註解 |
| **Extract Interface** | 要為測試注入替身，或有第二個實作在路上 | 從具體型別抽出消費端需要的方法子集 |
| **Split Loop** | 一個迴圈同時算兩件事 | 拆成兩個迴圈各做一件。效能疑慮先量再說，多數情況可忽略 |

## 搬移類

| 技法 | 什麼時候用 | 動作 |
| --- | --- | --- |
| **Move Function/Field** | Feature Envy——某方法一直在存取別的物件的資料 | 搬到資料所在的型別 |
| **Rename** | 名字沒說出責任，或名實不符 | 改名。**一律用 IDE 的 rename**，手改一定會漏 |
| **Change Function Declaration** | 參數順序怪、名字爛、參數太多 | 改簽名。公開 API 就先加新的、舊的轉呼叫新的、標記待廢棄 |
| **Introduce Parameter Object** | Data Clumps——同一組參數反覆一起出現 | 包成一個型別，那組參數通常是個沒被命名的領域概念 |
| **Pull Up / Push Down** | 行為放錯繼承層級 | 往上搬到共用、或往下搬到只有那個子型別需要的 |

## 簡化條件邏輯

| 技法 | 什麼時候用 | 動作 |
| --- | --- | --- |
| **Decompose Conditional** | `if` 條件式本身難讀 | 條件、then、else 各抽成具名函式 |
| **Replace Conditional with Polymorphism** | switch-on-type，加一種就要改同一處（違反 OCP） | 每個分支變成一個型別。這是通往 Strategy / State 的門 |
| **Replace Nested Conditional with Guard Clauses** | 巢狀 if 超過兩三層 | 例外情況提前 return，主要路徑留在最外層不縮排 |
| **Introduce Special Case / Null Object** | 到處在檢查 null 或某個特殊值 | 讓特殊情況也是一個型別，提供預設行為 |
| **Replace Magic Literal with Constant** | 裸露的數字或字串有隱含意義 | 具名常數 |

**Guard Clauses 是投報率最高的一個。** 它不需要新型別、不需要理解領域，就能把深巢狀的函式壓平，而且幾乎零風險。診斷看到「巢狀太深」時先做這個，做完常常會發現剩下的問題比原本看起來小。

## 簡化資料

| 技法 | 什麼時候用 | 動作 |
| --- | --- | --- |
| **Encapsulate Variable/Collection** | 可變狀態被外部直接改 | 包成存取方法，回傳副本或唯讀視圖 |
| **Replace Primitive with Object** | Primitive Obsession——用 string/int 表達訂單編號、金額、Email | 抽成帶驗證的 value object |
| **Replace Derived Variable with Query** | 有欄位是從別的欄位算出來的，還要手動維持同步 | 刪掉欄位，改成算的時候才算 |
| **Combine Functions into Class** | 一組函式都在傳同一批參數 | 那批參數是型別的狀態，函式是它的方法 |

## 移除類

| 技法 | 什麼時候用 | 動作 |
| --- | --- | --- |
| **Inline Function/Variable** | 間接層沒有帶來價值，名字沒比內容清楚 | 展開回去。**重構會往兩個方向走**，抽出來不是永遠正確 |
| **Remove Dead Code** | 沒有呼叫端 | 刪掉。版本控制記得住，註解掉的程式碼只會腐爛 |
| **Remove Middle Man** | 一個型別大半的方法只是轉呼叫另一個 | 讓呼叫方直接用被委派的那個 |
| **Remove Speculative Generality** | 只有一個實作的介面、沒人用的擴充點、預留參數 | 刪掉（YAGNI）。第二個實作真的出現時再抽 |

**Inline 與 Remove Speculative Generality 最常被忽略**，因為「加抽象」感覺像進步、「移除抽象」感覺像退步。實際上過度抽象的維護成本比重複高——重複很吵但看得見，錯誤的抽象是安靜的，而且會逼後來的人繞過它。

## 執行順序

同時看到多個問題時，由淺入深：

1. **Rename、Extract Variable、Guard Clauses** — 零風險，先做完會讓後面看得更清楚
2. **Extract Function、Remove Dead Code** — 低風險，範圍在單一檔案內
3. **Move Function/Field、Extract Class** — 中風險，跨檔案，會動到 import
4. **Replace Conditional with Polymorphism、Extract Interface** — 高風險，改變型別結構

先做 1 和 2 常常會讓 3 和 4 的正確切點自己浮出來。**反過來先動結構，會在還沒看清楚的情況下決定邊界。**

每個層級之間都要停下來跑測試並提交（步驟五）。
