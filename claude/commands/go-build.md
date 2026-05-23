---
description: Fix Go build errors, go vet warnings, and linter issues incrementally. Invokes the go-build-resolver agent for minimal, surgical fixes.
argument-hint: [package path | blank for ./...]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
---

# Go Build and Fix

> Orchestrates the `go-build-resolver` agent with the `golang-patterns` skill to incrementally fix Go build errors with minimal changes.

**Input**: $ARGUMENTS

---

## What This Command Does

1. **Run Diagnostics** — Execute `go build`, `go vet`, `staticcheck`.
2. **Parse Errors** — Group by file and sort by severity.
3. **Delegate Fixes** — Dispatch the `go-build-resolver` agent to repair one error at a time.
4. **Verify Each Fix** — Re-run build after each change.
5. **Report Summary** — Show what was fixed and what remains.

## When to Use

Use `/go-build` when:

- `go build ./...` fails with errors
- `go vet ./...` reports issues
- `golangci-lint run` shows warnings
- Module dependencies are broken
- After pulling changes that break the build

---

## Required Resources

This command MUST use:

- **Skill** `golang-patterns` — idiomatic Go conventions used to inform fix choices (no premature refactors).
- **Agent** `go-build-resolver` — defined in `claude/agents/go-build-resolver.md`. Specialist in minimal, surgical fixes for build / vet / lint errors. Stops after 3 failed attempts on the same error.

The command runs the build/lint commands itself; the agent proposes and applies the fixes.

---

## Workflow

### Phase 1 — DIAGNOSE

Run the diagnostic suite. Target = `$ARGUMENTS` if provided, else `./...`:

```bash
go build ${TARGET:-./...}
go vet ${TARGET:-./...}
staticcheck ${TARGET:-./...}      # if installed
golangci-lint run ${TARGET:-./...} # if installed
go mod verify
go mod tidy -v
```

Collect all errors and warnings. If the build is already green: stop with "Nothing to fix."

### Phase 2 — CLASSIFY

Group findings:

| Tier | Examples |
|---|---|
| **Build errors** | `undefined: X`, `cannot use X as Y`, `missing return`, `import cycle` |
| **Vet warnings** | Suspicious composite literals, shadowed vars, lock copies |
| **Lint warnings** | Style, unused params, naming |
| **Module issues** | Missing `go.sum`, stale `go.mod`, version conflicts |

Fix order: **Build → Vet → Lint → Module** (compilation first, then correctness, then style).

### Phase 3 — CONTEXT

Load the `golang-patterns` skill via the Skill tool so the agent's fixes follow project idioms.

### Phase 4 — DELEGATE (per error)

For each error in order:

1. Dispatch the `go-build-resolver` agent via Task tool with:
   - The specific error message and location
   - The current file contents
   - Constraint: **minimal change only** — no refactoring, no adjacent cleanup
   - Constraint: stop after 3 failed attempts on this error
2. Agent returns the proposed fix. Apply it.
3. Re-run the same diagnostic command from Phase 1 to verify the fix.
4. If the fix introduces new errors → revert, report blocker, move on.

### Phase 5 — VERIFY

After all errors processed:

```bash
go build ./...
go vet ./...
go test ./...   # smoke check that tests still compile
```

All three must pass. Race detector check:

```bash
go build -race ./...
```

### Phase 6 — REPORT

```
# Go Build Resolution

## Summary
| Metric | Count |
|---|---|
| Build errors fixed | <n> |
| Vet warnings fixed | <n> |
| Lint warnings fixed | <n> |
| Files modified | <n> |
| Remaining issues | <n> |

## Build Status
<PASS / BLOCKED — reason>

## Files Modified
<list>

## Unresolved
<list of errors agent couldn't fix in 3 attempts, with suggested next steps>
```

---

## Stop Conditions

The agent will stop and surface a blocker (not silently fail) when:

- Same error persists after 3 attempts
- A fix introduces more errors than it resolves
- Resolution requires architectural changes (multi-file restructure)
- Missing external dependencies that need `go get`

In all of these cases, the command reports the blocker and continues to the next error — it does not abort the whole run.

---

## Edge Cases

- **No `go.mod`** → Stop. Not a Go project.
- **`go mod tidy` removes a needed package** → Treat as blocker, surface to user (likely missing import).
- **Generated code error** (`*.pb.go`, mocks) → Skip and note; do not regenerate from inside this command.

---

## Related

- `/go-test` — Run tests after build succeeds.
- `/go-review` — Review code quality after build is green.
