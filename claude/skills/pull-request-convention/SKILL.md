---
name: pull-request-convention
description: Defines pull request title and description conventions for all repositories. Load this skill whenever you need to write, generate, validate, or review a GitHub pull request title or body — including when about to open a PR, checking whether a PR title follows the right format, or reviewing a PR description someone else wrote. Use when user says "PR title", "PR description", "validate this PR", "is this PR title ok", or any variant of writing/checking PRs. Also load this from inside `create-pr` and `create-detail-pr` for the title rules.
---

# Pull Request Convention

Standard pull request format used across all repositories. This skill owns the rules; the `create-pr` and `create-detail-pr` skills own the workflow.

## Title format

```
<type>(<scope>): <Summary starting with capital letter, no trailing period>
```

- **type** — required, from the table below
- **scope** — optional, short noun naming the area of change (e.g., `auth`, `api`, `alarm`, `cmd`)
- **summary** — required, **starts with a capital letter**, imperative mood, **no trailing period**

> Note: PR titles capitalize the summary; commit messages keep it lowercase. The two conventions are intentionally different — PR titles are more human-facing.

## Types

| Type       | When to use                                          |
| ---------- | ---------------------------------------------------- |
| `feat`     | New feature or capability                            |
| `fix`      | Bug fix                                              |
| `perf`     | Performance improvement                              |
| `refactor` | Code change with no behavior change                  |
| `test`     | Adding or fixing tests                               |
| `docs`     | Documentation only                                   |
| `chore`    | Maintenance, dependencies, tooling                   |
| `ci`       | CI/CD configuration                                  |
| `build`    | Build system changes                                 |
| `revert`   | Reverts a previous commit or PR                      |

For **breaking changes**, add `!` before the colon: `feat(api)!: Remove deprecated v1 alarm endpoints`

## Validation regex

```
^(feat|fix|perf|test|docs|refactor|build|ci|chore|revert)(\([a-zA-Z0-9 ]+\))?!?: [A-Z].+[^.]$
```

## Description principles

These apply to **every** PR body, regardless of whether it's a lean or detailed format:

- **Explain the why, not the what.** The diff already shows what changed; the description should explain motivation, constraints, and trade-offs that aren't visible in code.
- **No redundant diff summaries.** Don't restate file-by-file what changed if the diff already makes it obvious.
- **Link related issues.** Use `closes #123` / `fixes #456` so GitHub auto-closes them on merge.
- **Flag what's tricky.** If there's something a reviewer might miss (a subtle invariant, a deliberate trade-off, a known limitation), call it out.
- **Omit sections with nothing to say.** A "Notes" or "Risks" section with no real content is noise — delete it.

## Examples

Good titles:

```
feat(project): Add cloud-based camera support with bandwidth calculation
fix(auth): Resolve token refresh race condition on concurrent requests
refactor(alarm): Extract notification dispatch into domain service
chore: Upgrade Go to 1.25 and update dependencies
feat(api)!: Remove deprecated v1 alarm endpoints
revert(ci): Roll back race detector workflow
```

Bad titles and why:

```
Added login                       ← missing type
feat: added login.                ← lowercase summary, trailing period
FEAT: Add login                   ← uppercase type
feat(very long scope name): Add   ← scope should be short, no spaces
update stuff                      ← missing type, vague
fix: fix the bug                  ← lowercase, useless summary
```

## Validation checklist

When checking whether a PR title is valid:

- [ ] Starts with a recognized type (`feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `chore`, `ci`, `build`, `revert`)
- [ ] Scope, if present, is a short noun with no spaces in brackets
- [ ] `!` for breaking changes goes before the colon, not after the type
- [ ] Format is exactly `type: Summary` or `type(scope): Summary` (note the space after the colon)
- [ ] Summary starts with a **capital letter** and has **no trailing period**
- [ ] First line is concise (aim for ≤72 chars, but readability beats strict length)

When reviewing a PR description:

- [ ] Explains the **why**, not just the **what**
- [ ] No copy-paste of the diff in prose form
- [ ] Issues are linked if relevant
- [ ] Tricky parts are flagged for reviewers
- [ ] Empty boilerplate sections have been removed

If a title or description fails the checks, explain which rule it breaks and suggest a corrected version.

## Choosing the body format

The convention defines the *rules*, not the *template*. Two command skills implement complementary templates:

- **`create-pr`** — lean body (Summary / Changes / Notes). Use for day-to-day changes: refactors, bug fixes, small features, doc updates.
- **`create-detail-pr`** — detailed body adding Security / Testing / Impact / Checklist sections. Use for high-impact changes: auth, API, database, security, breaking changes, anything reviewers need extra confidence on.

When in doubt, start lean. Detailed sections that have nothing to say are worse than no sections at all.
