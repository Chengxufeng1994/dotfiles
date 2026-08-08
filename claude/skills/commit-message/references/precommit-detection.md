# Pre-commit 檢查偵測

原始的 `/commit-message` 命令寫死了 `pnpm lint && pnpm build`，只在 Node 專案有效。這份用偵測取代寫死。

## 偵測順序

**先看 repo 自己宣告了什麼，再猜語言慣例。** 專案自己寫下來的指令永遠比語言預設準確——`Makefile` 裡的 `make check` 可能同時跑 lint、vet、test，而語言預設只會跑到其中一項。

### 1. repo 已有 git hook

```bash
ls .git/hooks/pre-commit .husky/pre-commit .pre-commit-config.yaml 2>/dev/null
```

有的話 **不要手動再跑一次** —— `git commit` 會自己觸發。重複跑只是浪費時間。直接進 Step 3，並告訴使用者檢查交給 hook。

### 2. Makefile / Taskfile / justfile

```bash
grep -oE '^[a-z][a-z0-9_-]*:' Makefile 2>/dev/null | tr -d ':'
```

找 `lint`、`check`、`test`、`build`、`ci`、`verify` 這類 target。有 `check` 或 `verify` 通常就是專案指定的入口，優先用它。

Taskfile 用 `task --list`，justfile 用 `just --list`。

### 3. 語言慣例

| 偵測檔案 | 檢查指令 |
|---|---|
| `package.json` | 讀 `scripts` 欄位，跑實際存在的：`lint`、`typecheck`、`build`。套件管理員看 lock 檔：`pnpm-lock.yaml` → pnpm、`yarn.lock` → yarn、`bun.lockb` → bun、`package-lock.json` → npm |
| `go.mod` | `go build ./... && go vet ./...`；有 `.golangci.yml` 再加 `golangci-lint run` |
| `Cargo.toml` | `cargo check && cargo clippy -- -D warnings` |
| `pyproject.toml` / `setup.py` | 依設定檔內容：`ruff check .`、`mypy .`、`black --check .` |
| `*.csproj` / `*.sln` | `dotnet build` |
| `pom.xml` / `build.gradle` | `mvn -q compile` / `./gradlew build -x test` |

## 執行原則

**只跑靜態檢查與 build，不跑完整測試套件。** 測試可能要幾分鐘，會把「提交」這個動作變成需要等待的事，使用者下次就會繞過整個流程。要跑測試就明講預期時間，讓他決定。

**偵測不到就跳過，並明確說出來。**

```
沒有偵測到 lint 或 build 設定（找不到 Makefile / package.json / go.mod），跳過 pre-commit 檢查。
```

安靜地不檢查比不檢查更糟——使用者會以為檢查過了。這是 `CLAUDE.md` 的「Fail loud」直接命中的情況。

**檢查失敗時停下來問，不要自己決定：**

```
`go vet ./...` 失敗：

  internal/store/cache.go:47: unreachable code

要先修這個問題，還是照樣提交？
```

貼出實際錯誤輸出，不要只說「檢查失敗」——使用者需要錯誤內容才能判斷嚴重性。

## 跳過檢查

使用者說 `--no-verify`、「跳過檢查」、「不用檢查直接提交」時，跳過 Step 2 進 Step 3。

**但這不等於 `git commit --no-verify`。** repo 自己的 pre-commit hook 是專案的硬性要求，繞過它會讓壞掉的東西進到共用分支。使用者要跳過的是本流程的檢查步驟；要繞過 repo 的 hook 必須由他明確指定，而且值得先確認一次。
