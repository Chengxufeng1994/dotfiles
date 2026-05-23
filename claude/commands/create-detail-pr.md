---
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob, Skill
argument-hint: [optional context about the PR]
description: Open a GitHub pull request with a detailed body (Summary / Changes / Security / Testing / Risks / Checklist)
---

# Create Pull Request (detailed)

Open a GitHub pull request with a thorough body covering security, testing, and risk — for high-impact changes (auth, API contracts, database schema/migrations, security, financial logic, large cross-subsystem refactors). For day-to-day changes, use `/create-pr` instead.

Optional context from the user: $ARGUMENTS

## Step 0: Load the convention

**Before drafting anything, load the `pull-request-convention` skill.** It owns the title format rules (types, scope, validation regex, capitalization, breaking-change marker) and the shared description principles. Don't restate or guess them — read the skill.

## When to use this command (vs `/create-pr`)

Use `/create-detail-pr` when **any** of the following apply:

- Touches authentication, authorization, session, or token handling
- Changes a public API contract (especially with `!` breaking-change marker)
- Modifies database schema, migrations, or query patterns that affect data integrity
- Touches payment, billing, or other financial logic
- Adds or changes encryption, hashing, signing, or other crypto code
- Large refactor that crosses subsystem boundaries
- Reviewers have asked for more context than a lean body provides

Otherwise use `/create-pr` — empty boilerplate sections are worse than no sections.

## Step 1: Gather context

- Default base branch: !`gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
- Current branch: !`git branch --show-current`
- Upstream tracking: !`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "not-pushed"`
- Commits on this branch: !`git log $(git rev-parse --abbrev-ref HEAD) --not $(git for-each-ref --format='%(refname:short)' refs/remotes/origin/ | grep -v HEAD) --oneline 2>/dev/null | head -20`

## Step 2: Analyze every change that will land

Read the full diff against the base branch — every commit that will land in the PR:

```bash
BASE=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
git log $BASE..HEAD --format="%h %s"
git diff $BASE...HEAD
```

For a detailed PR, think through:

- **High-level purpose**: one sentence describing why this change exists
- **Key modifications**: grouped by concern or subsystem
- **Security impact**: what threats does this affect (mitigate, introduce, neutral)?
- **Test coverage**: what was tested, how, and what's intentionally not covered
- **Risk**: what could go wrong on rollout, and what's the rollback story

## Step 3: Push if needed

If the branch isn't tracking a remote:

```bash
git push -u origin HEAD
```

## Step 4: Draft title and body

**Title** — follow the rules from `pull-request-convention`. Don't guess the format.

**Body** — use this detailed template, but **delete any section that has nothing meaningful to say**:

```markdown
## Summary

<One or two sentences: what this PR does and why now.>

## Changes

- <Grouped bullets focused on the *why*, not file-by-file restatement>
- ...

## Security improvements

- <What threat this mitigates, or "Neutral — no security-relevant changes" if applicable>
- ...

## Testing

- <Unit tests added/changed and what they cover>
- <Integration / E2E tests if applicable>
- <Manual verification steps performed>

## Impact / Risks

- <Breaking changes, migrations, performance regressions, rollback story>
- <Anything that could go wrong on rollout>

## Checklist

- [ ] Unit tests added/updated
- [ ] Integration tests updated (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] Backward compatibility checked (or breaking change explicitly marked)
- [ ] Security implications reviewed

## Notes

<Optional: trade-offs, follow-up work, or context not obvious from the code. Omit if empty.>
```

Link issues with `closes #123` / `fixes #456` when relevant.

> **Empty section policy:** A `## Security improvements` heading followed by "N/A" or a blank Checklist is noise. Either fill it with real content or delete the section.

## Step 5: Create the PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Return the PR URL.
