# Releases & Tagging

Releases need to be reproducible, attributable, and rollback-able. Tags are the mechanism.

## Semantic Versioning

`MAJOR.MINOR.PATCH`

| Segment | Bump when | Example |
|---------|-----------|---------|
| MAJOR | Breaking change | 1.0.0 → 2.0.0 |
| MINOR | New feature, backward compatible | 1.0.0 → 1.1.0 |
| PATCH | Bug fix, backward compatible | 1.0.0 → 1.0.1 |

Pre-release suffixes:

```
1.2.0-alpha.1
1.2.0-beta.2
1.2.0-rc.1
1.2.0           ← final release
```

## Creating a Tag

**Always use annotated tags** (`-a`), not lightweight tags. Annotated tags include author, date, and message — they're proper objects in git history.

```bash
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Add OAuth2 login (#123)
- Add password reset flow (#145)

Fixes:
- Resolve login redirect loop (#156)

Breaking Changes:
- None"

git push origin v1.2.0
```

To push all tags at once: `git push --tags` (use sparingly — pushes every local tag).

## Listing & Inspecting Tags

```bash
git tag -l                          # All tags
git tag -l 'v1.*'                   # Filter by pattern
git show v1.2.0                     # Show tag's commit + message
git log v1.1.0..v1.2.0 --oneline    # Commits between two tags
```

## Deleting a Tag

```bash
git tag -d v1.2.0                          # Local
git push origin --delete v1.2.0            # Remote
```

Caution: deleting a published tag breaks anyone who's pinned to it.

## Changelog Generation

Manual changelog from git log:

```bash
git log v1.1.0..v1.2.0 --no-merges --pretty=format:'- %s (%h)'
```

Automated (Conventional Commits → CHANGELOG.md):

```bash
npx conventional-changelog -i CHANGELOG.md -s -r 0
```

If commits follow `commit-convention` (which they should), conventional-changelog can derive `feat:` → "Features", `fix:` → "Bug Fixes" automatically.

## Release Branches (GitFlow)

When you need to stabilize a release while `main` continues to move:

```bash
# Cut the release branch from develop
git checkout develop
git checkout -b release/1.2.0

# Bug fixes go to release branch
git commit -m "fix: address QA finding in payment flow"

# When ready, merge to main and tag
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"

# Merge back to develop so fixes aren't lost
git checkout develop
git merge --no-ff release/1.2.0

# Delete the release branch
git branch -d release/1.2.0
```

For GitHub Flow / Trunk-Based, you don't need release branches — just tag a commit on `main`.

## Hotfixes

Production bug that can't wait for the next release:

```bash
# Branch from the production tag
git checkout -b hotfix/cve-2026-1234 v1.2.0

# Fix
git commit -m "fix: patch SSRF in image proxy (CVE-2026-1234)"

# Merge to main and tag a patch release
git checkout main
git merge --no-ff hotfix/cve-2026-1234
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git push origin main v1.2.1

# If using GitFlow, also merge to develop
git checkout develop
git merge --no-ff hotfix/cve-2026-1234
```

## GitHub Releases

Tag + GitHub Release = downloadable artifact + release notes + changelog UI.

```bash
gh release create v1.2.0 \
  --title "v1.2.0" \
  --notes-file CHANGELOG.md \
  ./dist/app-1.2.0.tar.gz
```

Or auto-generate notes from PRs:

```bash
gh release create v1.2.0 --generate-notes
```

## Versioning Strategies for Non-Library Projects

Apps and services don't always need SemVer. Alternatives:

- **CalVer**: `2026.05.0` (year.month.patch) — clear release timeline
- **Build numbers**: `1234`, `1235` — simple, monotonic
- **Date+SHA**: `2026-05-23-a1b2c3d` — fully reproducible

Pick what matches how consumers refer to the product.

## Verification Before Tagging

- [ ] All tests pass on the target commit
- [ ] CHANGELOG updated
- [ ] Version bumped in `package.json` / `Cargo.toml` / `pyproject.toml` etc.
- [ ] Migration notes written if breaking
- [ ] Tag is annotated (`git tag -a`), not lightweight
- [ ] Tag pushed (`git push origin <tag>`)
- [ ] Release artifact built and attached (if applicable)
