# Merge vs Rebase

The golden rule: **never rewrite history that has been pushed to a shared branch.** Everything else is style.

## Merge

Creates a merge commit that joins two histories. Preserves the exact sequence of events.

```bash
git checkout main
git merge feature/user-auth
```

```
*   merge commit         ← created by `git merge`
|\
| * feature commit 3
| * feature commit 2
| * feature commit 1
|/
* main commit (before feature branched)
```

**Use merge when:**
- Integrating a feature branch into `main` or `develop`
- Multiple people have worked on the branch (history is *theirs*, not yours to rewrite)
- The branch is pushed and others may have based work on it
- You want the merge commit as a documented integration point

## Rebase

Replays your commits on top of the target branch, rewriting them so the history looks linear.

```bash
git checkout feature/user-auth
git rebase main
```

```
* feature commit 3 (rewritten — new SHA)
* feature commit 2 (rewritten — new SHA)
* feature commit 1 (rewritten — new SHA)
* main commit
```

**Use rebase when:**
- Updating a *local-only* feature branch with the latest main before opening a PR
- You want a clean linear history with no merge commits
- You're the only author of the branch

## Squash Merge

Collapses all branch commits into one when merging. Done in the PR UI ("Squash and merge") or locally:

```bash
git checkout main
git merge --squash feature/user-auth
git commit -m "feat: add user auth"
```

**Use squash merge when:**
- The team standard is one PR = one commit on main
- The branch has noisy intermediate commits ("fix typo", "address review")
- You want a clean main history without losing branch history (it's still on the PR)

## The Update-Before-PR Workflow

The most common rebase use case:

```bash
# You've been working on feature/x. Main has moved on.
git checkout feature/x
git fetch origin
git rebase origin/main

# Conflicts? Fix them, then:
git add <resolved-files>
git rebase --continue

# Push the rewritten history. --force-with-lease is safer than --force:
# it refuses to push if someone else pushed to your branch in the meantime.
git push --force-with-lease origin feature/x
```

## Interactive Rebase

Reorganize, squash, edit, or drop commits before merging:

```bash
git rebase -i origin/main
```

In the editor:

```
pick a1b2c3d Add validation
squash d4e5f6g Fix typo in validation
reword h7i8j9k Add tests
drop  m1n2o3p WIP debug logging
```

Commands:
- `pick` — keep as is
- `reword` — keep commit, edit message
- `edit` — pause to amend the commit
- `squash` — merge into previous, keep both messages
- `fixup` — merge into previous, discard this message
- `drop` — remove the commit entirely

## When Rebase Goes Wrong

If a rebase gets messy:

```bash
git rebase --abort         # Bail out, return to pre-rebase state
```

If you've already finished a bad rebase, `git reflog` shows every HEAD position. You can `git reset --hard <reflog-sha>` to restore.

## What NOT to Rebase

Never rebase if:
- The branch is pushed to a shared remote
- Others have based work on the branch
- The branch is a protected branch (`main`, `develop`, `release/*`)
- The commits have already been merged

If you rebase shared history, anyone who pulled the old version will have a divergent local branch and merge conflicts forever. Use `git revert` for already-shared mistakes.

## Team Policy Decision

Pick one and document it in `CONTRIBUTING.md`:

| Policy | Pros | Cons |
|--------|------|------|
| **Squash-merge PRs** | Clean linear main, one commit per PR | Loses development narrative |
| **Merge commits** | Preserves history, clear integration points | Noisy log if many small PRs |
| **Rebase-merge** | Linear main, preserves individual commits | Requires PR author to rebase before merge |

Most teams: **squash-merge for features, rebase before PR review.**
