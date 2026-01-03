# Refactor

接著你要進行設計的重構工作。

## Files

- $FILES

## Context

重構目標：

1. 遵守 SOLID 原則
   - SRP — Single Responsibility Principle
   - OCP — Open Closed Principle
   - LSP — Liskov Substitution Principle
   - ISP — Interface Segregation Principle
   - DIP — Dependency Inversion Principle
2. 遵守 KISS - Keep It Simple & Stupid 原則
3. 遵守 YAGNI - You Ain't Gonna Need It 原則
4. 遵守 DRY - Don't Repeat Yourself 原則
5. 適當的使用 Design Pattern

## 遵守流程

1. 程式碼問題診斷
   - 找出違反 SOLID 原則的地方
   - 找出潛在的壞味道（Code Smells）
   - 說明這段程式的責任與耦合問題
2. 物件導向分析
   - 對原始程式碼中的概念進行 OOA 分析（例如：有哪些潛在的物件或行為）
   - 依據功能抽出應有的 Class / Interface
   - 識別出哪裡應該使用設計模式（GoF Patterns）
3. 重構建議與設計模式應用
   - 運用適當的 Design Patterns（例如 Strategy, Factory, Observer, Decorator…）
   - 每個建議都說明原因與改善目標（易測試性、解耦、開放封閉、單一責任…）
4. 重構後的架構草圖（UML Class Diagram）
   - 提供重構後的簡單 UML 類別圖，顯示物件關係與責任劃分
5. 重構後程式碼
   - 使用 Go 撰寫完整、可編譯、遵守 SOLID 與 Clean Code 原則的程式碼
   - 模組需命名語意清楚，禁止出現 Helper, Impl, Util 等模糊命名
6. 比較前後版本優劣
   - 解釋重構後在擴充性、測試性、可讀性、依賴穩定性上的提升
7. 重構完之後要進行回歸測試，下達測試指令，並確保所有測試仍然通過, 如果有任一測試不通過，則要修正程式邏輯以確保所有測試都要通過
