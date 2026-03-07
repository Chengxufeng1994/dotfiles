---
name: create-pr
description: Creates GitHub pull requests with properly formatted conventional commits titles and focused descriptions. Use this skill whenever the user says /pr, "create a PR", "open a pull request", "submit for review", "push for review", or when they've just finished committing changes and want to get them reviewed. Trigger even if they just say "submit" or "push" in a coding context — they likely want a PR.
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob
---

# Create Pull Request

Create a GitHub pull request with a properly formatted title and a clear, focused description.

## Step 1: Gather context

Run these in parallel:

```bash
# What's the default base branch?
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

# What commits will be in the PR?
git log $(git rev-parse --abbrev-ref HEAD) --not $(git for-each-ref --format='%(refname:short)' refs/remotes/origin/ | grep -v HEAD) --oneline 2>/dev/null | head -20

# Is the branch pushed to remote?
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "not-pushed"
```

## Step 2: Analyze all changes

Read the full diff — not just the latest commit, but everything that will land in the PR:

```bash
BASE=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
git log $BASE..HEAD --format="%h %s"
git diff $BASE...HEAD
```

Understand:

- **What** changed (the diff shows this)
- **Why** these changes were made (this is what the PR description should explain)
- **Scope**: which area or package is primarily affected

## Step 3: Push if needed

If the branch isn't tracking a remote yet:

```bash
git push -u origin HEAD
```

## Step 4: Create the PR

### Title format

```
<type>(<scope>): <Summary starting with capital letter, no trailing period>
```

| Type       | When to use                         |
| ---------- | ----------------------------------- |
| `feat`     | New feature                         |
| `fix`      | Bug fix                             |
| `perf`     | Performance improvement             |
| `refactor` | Code change with no behavior change |
| `test`     | Adding or fixing tests              |
| `docs`     | Documentation only                  |
| `chore`    | Maintenance, dependencies, tooling  |
| `ci`       | CI/CD configuration                 |
| `build`    | Build system changes                |

For breaking changes, add `!` before the colon: `feat(api)!: Remove deprecated endpoints`

**Validation:** `^(feat|fix|perf|test|docs|refactor|build|ci|chore|revert)(\([a-zA-Z0-9 ]+\))?!?: [A-Z].+[^.]$`

### Body format

```markdown
## Summary

<One or two sentences: what this PR does and why.>

## Changes

- <What changed and why — group by concern if there are many>
- ...

## Notes

<Optional: anything reviewers should pay special attention to, tricky trade-offs, or context not obvious from the code. Omit this section entirely if there's nothing to flag.>
```

**Keep it lean:**

- Focus on the _why_ — the diff already shows the _what_
- No test plan sections or checkbox lists
- No redundant summaries of the diff
- Link to related issues if relevant: `closes #123` / `fixes #456`

### Run the command

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL when done.

## Examples

```
feat(project): Add cloud-based camera support with bandwidth calculation
fix(auth): Resolve token refresh race condition on concurrent requests
refactor(alarm): Extract notification dispatch into domain service
chore: Upgrade Go to 1.25 and update dependencies
feat(api)!: Remove deprecated v1 alarm endpoints
```
