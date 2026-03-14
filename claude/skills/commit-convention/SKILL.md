---
name: commit-convention
description: Defines commit message conventions for all repositories. Load this skill whenever you need to generate, write, or validate a git commit message — including when about to commit code, reviewing a commit message someone wrote, or checking if a message follows the right format. Use when user says "commit", "write a commit message", "check this commit", "is this commit message ok", or any variant of committing changes.
---

# Commit Message Convention

Standard commit format used across all repositories.

## Format

```
<type>[(<scope>)]: <description>

[optional body]
```

- **type** — required, from the list below
- **scope** — optional, short noun describing the area of change (e.g., `auth`, `api`, `db`, `cmd`)
- **description** — required, imperative mood, lowercase, no trailing period, ≤72 chars
- **body** — optional, separated from description by a blank line; explain *why*, not *what*

## Types

| Type | Use when |
|------|----------|
| `feat` | Adding a new feature or capability |
| `fix` | Fixing a bug |
| `refactor` | Code change that neither adds a feature nor fixes a bug |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `chore` | Build process, tooling, dependency updates |
| `perf` | Performance improvement |
| `ci` | CI/CD configuration changes |

## Description Rules

- **Imperative mood**: "add login" not "added login" or "adds login"
- **Lowercase**: first letter of description is lowercase
- **No trailing period**
- **≤72 characters** on the first line (type + scope + description combined)

## Examples

```
feat: add user authentication
fix(api): handle empty response body
refactor(auth): simplify token validation logic
docs: update README with setup instructions
test(db): add integration tests for connection pool
chore: upgrade Go to 1.22
perf(cache): reduce allocations in hot path
ci: add race detector to test workflow
```

With body:
```
fix(auth): prevent token expiry race condition

Token validation and refresh were not atomic, causing occasional
401s under high concurrency. Wrap both operations in a mutex.
```

Bad examples and why:
```
Fixed the bug               ← missing type
feat: Added login.          ← past tense, trailing period
FEAT: add login             ← uppercase type
feat(very long scope): add  ← scope should be short, no spaces
update stuff                ← vague, missing type
```

## Validation Checklist

When checking whether a commit message is valid:

- [ ] Starts with a recognized type (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`)
- [ ] Scope, if present, is a short lowercase noun with no spaces
- [ ] Format is exactly `type: description` or `type(scope): description`
- [ ] Description starts lowercase and has no trailing period
- [ ] First line is ≤72 characters total
- [ ] Body, if present, is separated from the first line by a blank line

If a message fails validation, explain which rule it breaks and suggest a corrected version.
