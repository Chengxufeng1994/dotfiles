---
description: Comprehensive Go code review for idiomatic patterns, concurrency safety, error handling, and security. Invokes the go-reviewer agent.
argument-hint: [file-path | PR-number | --staged]
allowed-tools: Read, Bash, Grep, Glob, Task
---

# Go Code Review

> Orchestrates the `go-reviewer` agent with the `golang-patterns` and `golang-testing` skills for Go-specific code review.

**Input**: $ARGUMENTS

---

## What This Command Does

1. **Identify Go Changes** — Find modified `.go` files via `git diff`.
2. **Run Static Analysis** — `go vet`, `staticcheck`, `golangci-lint`, `govulncheck`.
3. **Delegate Review** — Dispatch the `go-reviewer` agent for idiomatic / concurrency / error handling / security analysis.
4. **Generate Report** — Categorize findings by severity (CRITICAL / HIGH / MEDIUM / LOW).

## When to Use

Use `/go-review` when:

- After writing or modifying Go code
- Before committing Go changes
- Reviewing pull requests with Go code
- Onboarding to a new Go codebase
- Learning idiomatic Go patterns

---

## Severity Categories

The command briefs the agent with these Go-specific severity buckets. Phase 4 passes this contract to `go-reviewer`; Phase 5 maps them to the Decision Matrix.

### CRITICAL (Must Fix → BLOCK)

- SQL / command injection vulnerabilities
- Race conditions without synchronization
- Goroutine leaks
- Hardcoded credentials
- Unsafe pointer usage (`unsafe.Pointer` without justification)
- Ignored errors in critical paths

### HIGH (Should Fix → REQUEST CHANGES)

- Missing error wrapping with context (`fmt.Errorf("...: %w", err)`)
- `panic` instead of error returns
- `context.Context` not propagated through call chains
- Unbuffered channels causing potential deadlocks
- Interface-not-satisfied compile errors
- Missing mutex protection on shared mutable state

### MEDIUM (Consider → APPROVE WITH COMMENTS)

- Non-idiomatic code patterns (vs `golang-patterns` skill)
- Missing godoc comments on exported identifiers
- Inefficient string concatenation (use `strings.Builder` in loops)
- Slice not preallocated when length is known
- Table-driven tests not used where applicable

### LOW (Optional → APPROVE)

- Naming polish, comment style, formatting nits not caught by `gofmt`.

---

## Required Resources

This command MUST use:

- **Skill** `golang-patterns` — idiomatic Go conventions, error wrapping, context propagation, interface design.
- **Skill** `golang-testing` — test coverage expectations for review purposes.
- **Agent** `go-reviewer` — defined in `claude/agents/go-code-reviewer.md` (frontmatter `name: go-reviewer`). Expert reviewer for concurrency safety, error handling, security, and Go idioms.

The command runs static analysis itself (shell state required); the agent runs the conceptual review.

---

## Workflow

### Phase 1 — IDENTIFY

Find Go changes:

```bash
git diff --name-only HEAD | grep '\.go$'
git diff --staged --name-only | grep '\.go$'
```

If `$ARGUMENTS` is a file path → review that file.
If `$ARGUMENTS` is a PR number → `gh pr checkout <NUMBER>` first, then proceed.
If `$ARGUMENTS` is `--staged` → review staged changes only.
If empty → review all uncommitted Go changes.

If no Go files changed: stop with "Nothing to review."

### Phase 2 — STATIC ANALYSIS

Run the diagnostic gate:

```bash
go vet ./...
staticcheck ./...        # if installed
golangci-lint run ./...  # if installed
govulncheck ./...        # security vulns
go build -race ./...     # race-safe build check
```

Capture pass/fail per check. Any tool not installed → record as "skipped", don't abort.

### Phase 3 — CONTEXT

1. Read `CLAUDE.md` and `claude/rules/ecc/**/*.md` for project conventions.
2. Load `golang-patterns` and `golang-testing` skills via the Skill tool.

### Phase 4 — DELEGATE

Dispatch the `go-reviewer` agent via Task tool with:

- The full diff (or file contents if PR mode)
- Static analysis output from Phase 2
- Project conventions surfaced in Phase 3
- **The Severity Categories contract above** — agent must classify every finding into CRITICAL / HIGH / MEDIUM / LOW per those exact buckets
- Explicit instructions: apply Go-specific review (concurrency, error wrapping, context, interfaces), respect Pre-Report Gate, return zero findings if clean

The agent returns the structured findings. Do not re-review on top of it.

### Phase 5 — DECIDE

| Condition | Decision |
|---|---|
| Zero CRITICAL/HIGH, static analysis passes | **APPROVE** |
| Only MEDIUM/LOW, static analysis passes | **APPROVE WITH COMMENTS** |
| Any HIGH, or static analysis failures | **REQUEST CHANGES** |
| Any CRITICAL | **BLOCK** |

### Phase 6 — REPORT

Output combined report:

```
# Go Code Review

## Files Reviewed
<list>

## Static Analysis
| Tool | Result |
|---|---|
| go vet | Pass / Fail / Skipped |
| staticcheck | Pass / Fail / Skipped |
| golangci-lint | Pass / Fail / Skipped |
| govulncheck | Pass / Fail / Skipped |
| go build -race | Pass / Fail |

## Findings
<agent output, grouped by severity>

## Summary
- CRITICAL: <n>
- HIGH: <n>
- MEDIUM: <n>
- LOW: <n>

Verdict: <APPROVE | APPROVE WITH COMMENTS | REQUEST CHANGES | BLOCK>
```

---

## Edge Cases

- **No `go.mod`** → Stop. Use `/code-review` for non-Go projects.
- **Tool not installed** (`staticcheck`, `golangci-lint`, `govulncheck`) → Note as skipped; review proceeds.
- **Agent returns zero findings** → A clean review is valid. Approve without manufacturing nits.
- **Race detector reports DATA RACE** → Treat as CRITICAL; BLOCK regardless of agent findings.

---

## Related

- `/go-test` — Run tests with TDD discipline before review.
- `/go-build` — Fix build errors before review.
- `/code-review` — Non-Go-specific review flow.
