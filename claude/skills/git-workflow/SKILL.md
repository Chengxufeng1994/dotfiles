---
name: git-workflow
description: Git workflow discipline — branching strategy selection, atomic commit cadence, save-point patterns, merge vs rebase decisions, conflict resolution, git worktrees for parallel work, and release tagging. Use whenever starting a new branch, deciding when/how to commit, integrating long-lived branches, picking between merge or rebase, resolving merge conflicts, setting up parallel agent workspaces, cutting a release, or when commits are accumulating without discipline. Does NOT cover commit message formatting (use commit-convention) or PR descriptions (use pull-request-convention).
---

# Git Workflow

Git is the safety net. Commits are save points, branches are sandboxes, history is documentation. When AI agents generate code quickly, disciplined version control is what keeps the work reviewable, revertable, and integrable.

This skill covers the **workflow and strategy** layer of git. For the *format* of commit messages, defer to `commit-convention`. For PR titles/descriptions, defer to `pull-request-convention`.

## When to Use

- Starting a new feature or fix → pick a branch strategy and naming
- About to commit → check atomicity, scope, and save-point discipline
- Feature branch is behind main → decide merge vs rebase
- Merge conflict appeared → resolve without losing work
- Running multiple agents in parallel → set up worktrees
- Cutting a release → tag and version correctly
- Commits are piling up without structure → re-establish cadence

## Core Principles

### 1. Atomic Commits, Often

Each commit does **one logical thing**. Commit each working slice — don't accumulate.

```
Good cadence:
  Implement slice → Test → Verify → Commit → Next slice

Bad cadence:
  Implement everything → Hope it works → Giant commit
```

If a change breaks something, `git reset --hard HEAD` returns to the last known-good state. You never lose more than one increment.

### 2. Separate Concerns Across Commits

Don't mix formatting with behavior. Don't mix refactor with feature. Each *kind* of change is a separate commit, and ideally a separate PR.

```bash
# Good
git commit -m "refactor: extract validation to shared util"
git commit -m "feat: add phone validation to signup"

# Bad
git commit -m "refactor validation and add phone field"
```

Small cleanups (renaming a variable touched anyway) can stay with the feature commit at the author's discretion. The principle: a reviewer should be able to revert one concern without unwinding the other.

### 3. Short-Lived Branches

Long-lived branches are hidden costs. Every day a branch lives, it accumulates merge risk and drifts from main.

- **Target: merge within 1-3 days.**
- **Prefer feature flags** over branches for incomplete work that needs to ship gradually.
- **Delete branches after merge.**

### 4. Scope Discipline

Touch only what the task requires. After any change, output a change summary:

```
CHANGES MADE:
- src/routes/tasks.ts: Added validation middleware to POST endpoint
- src/lib/validation.ts: Added TaskCreateSchema using Zod

INTENTIONALLY NOT TOUCHED:
- src/routes/auth.ts: Has similar gap but out of scope
- src/middleware/error.ts: Error format could improve (separate task)

POTENTIAL CONCERNS:
- Zod schema is strict — rejects extra fields. Confirm desired.
```

The "INTENTIONALLY NOT TOUCHED" section is the most important. It proves scope discipline and gives reviewers a map.

### 5. Pre-Commit Hygiene

Before staging:

```bash
git diff --staged                              # Read what you're about to commit
git diff --staged | grep -iE 'password|secret|api[_-]?key|token'   # Sniff for secrets
# Run the project's formatter, linter, tests, and type checker
```

Automate with pre-commit hooks (husky + lint-staged, or `.git/hooks/pre-commit`). Never use `--no-verify` to bypass hooks unless the user explicitly asks.

## Branching Strategy

Pick a strategy that matches team size and release cadence. Most teams should default to **GitHub Flow** or **Trunk-Based Development**. Reserve GitFlow for scheduled releases with formal QA cycles.

| Strategy | Team size | Release cadence | Best for |
|----------|-----------|-----------------|----------|
| **GitHub Flow** | Any | Continuous | SaaS, web apps, startups (Recommended default) |
| **Trunk-Based** | 5+ experienced devs | Multiple/day | High-velocity teams with feature flags |
| **GitFlow** | 10+ | Scheduled | Enterprise, regulated, versioned products |

For decision rules, diagrams, and adoption checklists, read `references/branching-strategies.md`.

### Branch Naming

```
feature/<short-description>      → feature/task-creation
fix/<short-description>          → fix/duplicate-tasks
chore/<short-description>        → chore/update-deps
refactor/<short-description>     → refactor/auth-module
hotfix/<short-description>       → hotfix/cve-2026-1234
```

Prefer kebab-case. If the team uses ticket IDs, prefix them: `feature/JIRA-123-payment-flow`.

## The Save-Point Pattern

```
Start work
  │
  ├── Make a change
  │   ├── Tests pass? → Commit → Continue
  │   └── Tests fail? → Revert to last commit → Investigate
  │
  └── Feature complete → Clean linear history of working states
```

This is especially important for AI-assisted coding. If the agent goes off the rails, the last commit is always a safe landing.

## Merge vs Rebase

**Golden rule: never rewrite history that has been pushed to a shared branch.**

- **Merge** when integrating a feature branch into main, when others may have based work on the branch, or when you want to preserve the development narrative.
- **Rebase** to update your *local-only* feature branch with the latest main before opening a PR. Result is a linear history that's easier to read.
- **Squash-merge** in the PR UI is a third option — keeps main linear without rebasing locally.

```bash
# Update feature branch with latest main (rebase, local only)
git fetch origin
git rebase origin/main
git push --force-with-lease origin feature/x  # only if you're sole author
```

For full rebase workflows, interactive rebase, and what to do when rebase goes wrong, read `references/merge-vs-rebase.md`.

## Conflict Resolution

When a conflict appears:

```bash
git status                          # See conflicted files
# Open file — markers show <<<<<<< HEAD / ======= / >>>>>>> branch
# Edit to keep correct content, remove markers
git add <resolved-file>
git commit                          # for merge, or:
git rebase --continue               # for rebase
```

Quick escape hatches:

```bash
git checkout --ours <file>          # Keep main's version
git checkout --theirs <file>        # Keep incoming branch's version
git merge --abort                   # or: git rebase --abort
```

For prevention strategies, complex conflicts, and the `rerere` workflow, read `references/conflict-resolution.md`.

## Git Worktrees (Parallel Agent Work)

When you want multiple agents to work on different branches simultaneously without stepping on each other:

```bash
# Create a worktree for each branch in a sibling directory
git worktree add ../project-feature-a feature/task-creation
git worktree add ../project-feature-b feature/user-settings

# Each is a real working tree with its own checked-out branch
# Agents run independently — no branch switching, no interference

# List active worktrees
git worktree list

# When done
git worktree remove ../project-feature-a
```

Benefits:
- True parallelism — no `git checkout` thrashing
- Isolation — a failed experiment is a `rm -rf` away
- Shared object store — disk-cheap compared to multiple clones

## Releases & Tagging

Use **Semantic Versioning**: `MAJOR.MINOR.PATCH`.

```bash
# Annotated tag with release notes
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

For changelog generation, release branches, and hotfix flows, read `references/release-tagging.md`.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "I'll commit when the feature is done" | One giant commit can't be reviewed, debugged, or partially reverted. Commit slices. |
| "I'll squash it all later" | Squashing destroys the development narrative. Prefer clean incremental commits from the start. |
| "Branches add overhead" | Short-lived branches are free. Long-lived branches are the cost. |
| "I'll split this PR later" | Splitting after the fact is harder than committing atomically from the start. |
| "Rebase is dangerous" | Rebase is dangerous on *shared* history. On your own local branch it's clean and safe. |
| "I'll just `git push --force`" | `--force-with-lease` instead, and never on shared branches. |

## Red Flags

- Uncommitted changes accumulating beyond one logical slice
- Commit messages like "fix", "update", "wip", "misc"
- Formatting changes mixed with behavior changes in one commit
- A branch older than a week without a rebase
- `git push --force` on `main`, `develop`, or any shared branch
- `.env`, build output, or `node_modules/` committed
- No `.gitignore` in the repo

## Verification Checklist

Before every commit:

- [ ] Diff reviewed (`git diff --staged`)
- [ ] One logical concern only
- [ ] No secrets in the diff
- [ ] Tests pass locally
- [ ] No formatting-only changes mixed with behavior
- [ ] Commit message follows `commit-convention` (delegate to that skill)
- [ ] `.gitignore` covers env, build, IDE, OS files

Before opening a PR:

- [ ] Branch rebased onto latest main (if local) or merged with main (if shared)
- [ ] Branch size under ~300 lines if possible, ~1000 hard cap
- [ ] CI green locally
- [ ] PR body follows `pull-request-convention`

## Related Skills

- `commit-convention` — Commit message format (type, scope, body)
- `pull-request-convention` — PR title and body conventions
- `create-pr` / `create-detail-pr` — Open PRs from the command line
