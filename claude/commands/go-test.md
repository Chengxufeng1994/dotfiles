---
description: TDD workflow for Go — design via test-engineer, enforce table-driven + race + 80% coverage
argument-hint: [feature description | file path | bug description]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
---

# Go TDD

> Orchestrates the `test-engineer` agent with the `golang-testing` and `test-driven-development` skills to drive a strict RED → GREEN → REFACTOR loop in Go.

**Input**: $ARGUMENTS

---

## What This Command Does

1. **Define Types/Interfaces** — Scaffold function signatures first.
2. **Write Table-Driven Tests** — Create comprehensive test cases (RED).
3. **Run Tests** — Verify tests fail for the right reason.
4. **Implement Code** — Write minimal code to pass (GREEN).
5. **Refactor** — Improve while keeping tests green.
6. **Check Coverage** — Ensure ≥80% (general) / ≥90% (public APIs) / 100% (critical logic).

## When to Use

Use `/go-test` when:

- Implementing new Go functions
- Adding test coverage to existing code
- Fixing bugs (write failing test first — Prove-It mode)
- Building critical business logic
- Learning TDD workflow in Go

---

## Required Resources

This command MUST use:

- **Skill** `golang-testing` — table-driven tests, `t.Run`, `t.Parallel`, `t.Helper`, race detection, coverage commands, Go-idiomatic patterns.
- **Skill** `test-driven-development` — RED / GREEN / REFACTOR discipline, Prove-It pattern for bugs, behavior-first testing.
- **Agent** `test-engineer` — designs test cases across the 5-scenario matrix (happy / empty / boundary / error / concurrency), produces coverage-gap analysis, and applies Prove-It when the input is a bug.

The command itself runs `go test` and judges pass/fail — those steps cannot be delegated (subagents lose shell state on return).

---

## Workflow

### Phase 1 — UNDERSTAND

1. Parse `$ARGUMENTS`. Classify intent:
   - **Feature** — new function or package to implement.
   - **Coverage** — existing file/package needs more tests.
   - **Bug** — Prove-It mode: write a failing test that reproduces the bug, stop before fixing.
2. Read the target code (if it exists) and any neighboring tests to capture project conventions.
3. Load the `golang-testing` and `test-driven-development` skills via the Skill tool.

### Phase 2 — DESIGN (delegate)

Dispatch the `test-engineer` agent via Task tool with **explicit Go constraints in the prompt**:

```
Design tests for $ARGUMENTS.

OUTPUT REQUIREMENTS (Go-specific, override your defaults):
- Express cases as a Go table-driven slice of anonymous structs, NOT describe/it.
- Use `t.Run(tt.name, ...)` subtests for each row.
- Cover the 5-scenario matrix: happy / empty / boundary / error / concurrency.
- For concurrency cases, note whether `t.Parallel()` applies.
- For external boundaries (DB, HTTP, filesystem), specify where mocks/fakes go.

MODE:
- If intent is "bug" → Prove-It only. Write the failing test, STOP. Do not propose the fix.
- If intent is "feature" or "coverage" → full case design + priority list.

Return: (1) the table-driven test source, (2) the function signature(s) under test,
(3) a priority-ranked list of any additional cases you couldn't fit.
```

### Phase 3 — RED

1. Write the function signature(s) the agent returned with a `panic("not implemented")` body.
2. Write the table-driven test file the agent designed.
3. Run:

```bash
go test ./<package>/... -run <TestName>
```

4. Confirm the test FAILS for the expected reason (panic / wrong output). If it passes immediately, the test is wrong — go back to Phase 2.

### Phase 4 — GREEN

1. Implement the minimal code needed to satisfy the failing cases. No speculative additions.
2. Run the same `go test` invocation. Confirm PASS.
3. If any case still fails, **fix the implementation, not the test** (unless the test itself was wrong — say so explicitly).

### Phase 5 — REFACTOR

1. Clean up the implementation while tests stay green.
2. Re-run tests after each meaningful change.
3. Stop refactoring when the next change would alter behavior or no obvious improvement remains.

### Phase 6 — VERIFY

Run the full verification gate:

```bash
go test -race -cover ./<package>/...
```

| Gate | Requirement |
|---|---|
| Race detector | Must pass — any DATA RACE output blocks completion |
| Coverage | ≥ 80% for general code, ≥ 90% for public APIs, 100% for critical business logic |
| All tests | PASS |

If coverage is below target, return to Phase 2 with the gap as new `$ARGUMENTS`.

### Phase 7 — REPORT

Output a concise summary:

```
TDD complete: <feature/coverage/bug>

Files:
  + <new test files>
  + <new source files>

Tests added: <N> cases across <M> subtests
Coverage:    <before>% → <after>% (target: ≥80%)
Race:        pass / FAIL
```

---

## Bug Mode (Prove-It) Specifics

When `$ARGUMENTS` describes a bug:

1. Phase 2 → agent writes ONLY the failing test.
2. Phase 3 → run it, confirm RED.
3. **Stop here.** Report the failing test and the suspected root cause from the agent. Do not auto-implement the fix — that's a separate decision for the user.
4. The user explicitly requests the fix → re-enter at Phase 4.

This prevents the command from silently merging "wrote a test" and "wrote a fix" into one opaque step.

---

## Edge Cases

- **No `go.mod`** → Stop. This command is Go-specific.
- **Agent returns non-table-driven output (describe/it)** → Reject and re-dispatch with the constraint repeated. Do not paper over with manual translation.
- **Existing tests already cover the input** → Report coverage as-is; skip to Phase 6 verification only.
- **Generated code (`*.pb.go`, mocks)** → Exclude from coverage targets.

---

## Related

- `/go-build` — fix build errors before running tests.
- `/go-review` — review the implementation after this command completes.
- Skill `golang-patterns` — broader Go idioms beyond testing.
