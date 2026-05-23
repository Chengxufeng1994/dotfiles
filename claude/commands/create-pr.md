---
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob, Skill
argument-hint: [optional context about the PR]
description: Open a GitHub pull request with a lean body (Summary / Changes / Notes)
---

# Create Pull Request (lean)

Open a GitHub pull request with a lightweight body — for day-to-day changes (small features, refactors, bug fixes, doc updates, dependency bumps). For high-impact changes (auth, API contracts, database, security), use `/create-detail-pr` instead.

Optional context from the user: $ARGUMENTS

## Step 0: Load the convention

**Before drafting anything, load the `pull-request-convention` skill.** It owns the title format rules (types, scope, validation regex, capitalization, breaking-change marker) and the shared description principles. Don't restate or guess them — read the skill.

## Step 1: Gather context

- Default base branch: !`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
- Current branch: !`git branch --show-current`
- Upstream tracking: !`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "not-pushed"`
- Commits on this branch: !`git log $(git rev-parse --abbrev-ref HEAD) --not $(git for-each-ref --format='%(refname:short)' refs/remotes/origin/ | grep -v HEAD) --oneline 2>/dev/null | head -20`

## Step 2: Analyze every change that will land

Read the full diff against the base branch — not just the latest commit:

```bash
BASE=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
git log $BASE..HEAD --format="%h %s"
git diff $BASE...HEAD
```

Focus on the **why**, not the *what*. The diff already shows what changed; the body should explain motivation and trade-offs.

## Step 3: Push if needed

If the branch isn't tracking a remote:

```bash
git push -u origin HEAD
```

## Step 4: Draft title and body

**Title** — follow the rules from `pull-request-convention`. Don't guess the format.

**Body** — use this lean template:

```markdown
## Summary

<One or two sentences: what this PR does and why.>

## Changes

- <Grouped bullets focused on *why* changes were made, not a file-by-file restatement>
- ...

## Notes

<Optional: anything reviewers should pay special attention to. Omit the section entirely if there's nothing to flag.>
```

Link issues with `closes #123` / `fixes #456` when relevant.

## Step 5: Create the PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL.
