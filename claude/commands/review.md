---
description: Code review — local uncommitted changes or GitHub PR (pass PR number/URL for PR mode)
argument-hint: [pr-number | pr-url | blank for local review]
allowed-tools: Read, Bash, Grep, Glob, Task
---

# Code Review

> Workflow adapted from affaan-m/ECC. Orchestrates the `code-reviewer` agent using the `code-review-and-quality` skill methodology.

**Input**: $ARGUMENTS

---

## Mode Selection

If `$ARGUMENTS` contains a PR number, PR URL, or `--pr` → **PR Review Mode**.
Otherwise → **Local Review Mode**.

---

## Required Resources

This command MUST use:

- **Skill** `code-review-and-quality` — provides the five-axis methodology (correctness, readability, architecture, security, performance), severity prefixes, change sizing, and review checklist. Load it before Phase 3.
- **Skill** `security-and-hardening` — deepens the Security axis of every review with OWASP Top 10, threat modeling, and secure-by-default patterns. Loaded in Phase 2.
- **Skill** `code-simplification` — deepens the Readability & Simplicity axis with concrete simplification techniques (dead code, nested logic, naming, abstraction reduction). Loaded in Phase 2.
- **Skill** `performance-optimization` — deepens the Performance axis with profiling-driven analysis (N+1, unbounded loops, memory pressure, blocking I/O, Core Web Vitals). Loaded in Phase 2.
- **Agent** `code-reviewer` — executor with confidence-based filtering, Pre-Report Gate (line + failure scenario + verified context for HIGH/CRITICAL), and a curated false-positive skip list. Dispatch via the Task tool for Phase 3.

The command itself does not duplicate the checklist — it orchestrates context gathering, delegates the review, then handles validation and publishing.

---

## Local Review Mode

### Phase 1 — GATHER

```bash
git status --porcelain
git diff --name-only HEAD
git diff --stat HEAD~5
git log --oneline -5
git diff           # unstaged
git diff --staged  # staged
```

If no changes: stop with "Nothing to review."

### Phase 2 — CONTEXT

1. Read `CLAUDE.md` (repo) and any `claude/rules/*.md` to capture project conventions.
2. Load the `code-review-and-quality` skill via the Skill tool.
3. Load the `security-and-hardening` skill via the Skill tool — security is a first-class dimension of every review, not an opt-in.
4. Load the `code-simplification` skill via the Skill tool — readability and simplicity are checked against concrete simplification techniques, not vibes.
5. Load the `performance-optimization` skill via the Skill tool — Performance axis uses its profiling patterns and bottleneck checklist.

### Phase 3 — DELEGATE

Dispatch the `code-reviewer` agent via Task tool with:

- The full diff (or file paths if the diff is large)
- A pointer to the project rules surfaced in Phase 2
- Explicit instructions: apply the five-axis review with **(a)** `security-and-hardening` driving the Security axis, **(b)** `code-simplification` techniques informing the Readability axis, **(c)** `performance-optimization` patterns informing the Performance axis. Use Pre-Report Gate, respect the false-positive skip list, return zero findings if the diff is clean

The agent returns the structured findings table. Do not re-review on top of it.

### Phase 4 — VALIDATE (Go projects)

If `go.mod` exists at repo root:

```bash
go vet ./...
golangci-lint run ./... 2>/dev/null  # if installed
go test -race -cover ./...
go build ./...
```

Record pass/fail for each. Non-Go projects: skip and note in the report.

### Phase 5 — DECIDE & REPORT

Apply the [Decision Matrix](#decision-matrix). Output findings to stdout using the agent's summary format. Block commit if any CRITICAL or HIGH issue is present.

---

## PR Review Mode

### Phase 1 — FETCH

Parse `$ARGUMENTS`:

| Input | Action |
|---|---|
| Number (e.g. `42`) | Use as PR number |
| URL (`github.com/.../pull/42`) | Extract PR number |
| Branch name | Resolve via `gh pr list --head <branch>` |

```bash
gh pr view <NUMBER> --json number,title,body,author,baseRefName,headRefName,changedFiles,additions,deletions
gh pr diff <NUMBER>
```

If PR not found, stop. Store metadata for later phases.

### Phase 2 — CONTEXT

1. Read `CLAUDE.md` and `claude/rules/*.md`.
2. Check `.claude/plans/`, `.claude/reviews/`, `tasks/todo.md` for related context.
3. Parse PR description for goals, linked issues, test plans.
4. Categorize changed files: source / test / config / docs.
5. Load the `code-review-and-quality` skill via the Skill tool.
6. Load the `security-and-hardening` skill via the Skill tool — security is a first-class dimension of every review.
7. Load the `code-simplification` skill via the Skill tool — Readability axis uses its concrete techniques, not vibes.
8. Load the `performance-optimization` skill via the Skill tool — Performance axis uses its profiling patterns and bottleneck checklist.

### Phase 3 — DELEGATE

Fetch full file contents at the PR head revision:

```bash
gh pr diff <NUMBER> --name-only | while IFS= read -r file; do
  gh api "repos/{owner}/{repo}/contents/$file?ref=<head-branch>" --jq '.content' | base64 -d
done
```

Dispatch the `code-reviewer` agent via Task tool with:

- PR metadata (title, intent, base/head refs)
- Full file contents at head revision (not just diff hunks)
- Project rules surfaced in Phase 2
- Instruction to produce findings per the skill's five-axis framework and the agent's Pre-Report Gate

### Phase 4 — VALIDATE (Go projects)

Checkout PR locally if needed, then run the same Go validation as Local Mode Phase 4. Record results.

### Phase 5 — DECIDE

Apply the [Decision Matrix](#decision-matrix) below.

Special cases:
- Draft PR → always **COMMENT** (never approve/block).
- Docs/config-only PR → lighter review.
- Explicit `--approve` / `--request-changes` flag → override decision (still report all findings).

### Phase 6 — REPORT

Write artifact to `.claude/reviews/pr-<NUMBER>-review.md`:

```markdown
# PR Review: #<NUMBER> — <TITLE>

**Reviewed**: <date>
**Author**: <author>
**Branch**: <head> → <base>
**Decision**: APPROVE | APPROVE WITH COMMENTS | REQUEST CHANGES | BLOCK

## Summary
<1-2 sentence assessment>

## Findings
<agent output, grouped by severity: CRITICAL / HIGH / MEDIUM / LOW>

## Validation Results

| Check | Result |
|---|---|
| go vet | Pass / Fail / Skipped |
| golangci-lint | Pass / Fail / Skipped |
| go test -race -cover | Pass / Fail / Skipped |
| go build | Pass / Fail / Skipped |

## Files Reviewed
<list with change type: Added / Modified / Deleted>
```

### Phase 7 — PUBLISH

```bash
# APPROVE
gh pr review <NUMBER> --approve --body "<summary>"

# REQUEST CHANGES
gh pr review <NUMBER> --request-changes --body "<summary with required fixes>"

# COMMENT (draft PR or BLOCK)
gh pr review <NUMBER> --comment --body "<summary>"
```

Inline comments on specific lines:

```bash
gh api "repos/{owner}/{repo}/pulls/<NUMBER>/comments" \
  -f body="<comment>" \
  -f path="<file>" \
  -F line=<line-number> \
  -f side="RIGHT" \
  -f commit_id="$(gh pr view <NUMBER> --json headRefOid --jq .headRefOid)"
```

Batch multiple inline comments in one review:

```bash
gh api "repos/{owner}/{repo}/pulls/<NUMBER>/reviews" \
  -f event="COMMENT" \
  -f body="<overall summary>" \
  --input comments.json
# comments.json: [{"path": "file", "line": N, "body": "comment"}, ...]
```

### Phase 8 — OUTPUT

```
PR #<NUMBER>: <TITLE>
Decision: <APPROVE | APPROVE WITH COMMENTS | REQUEST CHANGES | BLOCK>

Issues: <critical> critical, <high> high, <medium> medium, <low> low
Validation: <pass>/<total> checks passed

Artifacts:
  Review: .claude/reviews/pr-<NUMBER>-review.md
  GitHub: <PR URL>

Next steps:
  - <contextual suggestions based on decision>
```

---

## Decision Matrix

| Condition | Decision |
|---|---|
| Zero CRITICAL/HIGH, validation passes | **APPROVE** |
| Only MEDIUM/LOW, validation passes | **APPROVE WITH COMMENTS** |
| Any HIGH, or validation failures | **REQUEST CHANGES** |
| Any CRITICAL | **BLOCK** |

Severity definitions and prefixes (`Critical:`, `Nit:`, `Optional:`, `FYI`) come from the `code-review-and-quality` skill — do not redefine them here.

---

## Edge Cases

- **No `gh` CLI** → Local-only review; skip Phase 7. Warn the user.
- **Diverged branches** → Suggest `git fetch origin && git rebase origin/<base>` before review.
- **Large PRs (>50 files or >1000 lines)** → The skill recommends splitting. Warn the user and prioritize source > tests > config/docs.
- **Non-Go repo** → Skip Phase 4 with note; review still proceeds.
- **Agent returns zero findings** → A clean review is valid. Approve without manufacturing nits (skill's "Common Rationalizations" section).

---

## Merge Policy

CRITICAL or HIGH issues block merge. Never approve code containing security vulnerabilities. Refer to the `code-review-and-quality` skill for the full approval standard.
