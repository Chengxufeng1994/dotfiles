# Conflict Resolution

Conflicts are inevitable. The goal is to resolve them deliberately without losing work.

## Identifying Conflicts

```bash
git status
```

Output during conflict:

```
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   src/auth/login.ts
```

## Conflict Markers

Git inserts markers into the conflicted file:

```
<<<<<<< HEAD
// content from the current branch (HEAD)
const sessionTimeout = 3600;
=======
// content from the incoming branch
const sessionTimeout = 7200;
>>>>>>> feature/user-auth
```

- `HEAD` block — what's currently on your branch
- `=======` — separator
- Below — what's coming in from the branch being merged or rebased onto

**Edit the file to remove markers** and keep the correct combination. Sometimes that means picking one side, sometimes a merge of both.

## Resolution Workflow

```bash
# 1. See what's conflicted
git status

# 2. Open each file, resolve manually
$EDITOR src/auth/login.ts

# 3. Stage the resolved file
git add src/auth/login.ts

# 4. Finish the operation
git commit            # if you were merging
git rebase --continue # if you were rebasing
git cherry-pick --continue  # if cherry-picking
```

## Escape Hatches

```bash
# Keep your branch's version entirely
git checkout --ours <file>

# Keep the incoming branch's version entirely
git checkout --theirs <file>

# Bail out of the operation
git merge --abort
git rebase --abort
git cherry-pick --abort
```

Note: during a rebase, `--ours` and `--theirs` are *swapped* relative to a merge — because rebase replays your commits onto the target, so the "current" side is the target branch.

## Using a Mergetool

For complex three-way conflicts (lots of overlapping edits), a visual mergetool helps:

```bash
git mergetool
```

Configure your preferred tool once:

```bash
git config --global merge.tool vimdiff   # or: vscode, meld, kdiff3
```

VS Code as mergetool:

```bash
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
```

## Prevention

Most conflicts are preventable:

1. **Keep branches short** — merge within 1-3 days
2. **Rebase frequently** — pull latest main into your branch often
3. **Coordinate on shared files** — if two devs need to touch `routes.ts`, talk first
4. **Use feature flags** — avoid long-lived branches entirely
5. **Make small PRs** — small surface area = small conflict surface
6. **Format consistently** — agree on a formatter so style differences don't pollute diffs

## `git rerere` (Reuse Recorded Resolution)

If you keep resolving the same conflict (common during long rebases), enable rerere:

```bash
git config --global rerere.enabled true
```

Git records how you resolved each conflict and applies the same resolution automatically next time. Saves significant time on rebase-heavy workflows.

## Semantic vs Textual Conflicts

Git only detects **textual** conflicts (same lines changed). It misses **semantic** conflicts:

- Your branch renames a function `foo()` → `bar()`
- Their branch adds a new caller `foo()`
- Git merges cleanly → broken code at runtime

**Mitigation:** always run tests and type checking after resolving conflicts, not just `git status`.

## When Conflict Resolution Reveals a Real Problem

Sometimes a conflict reveals that two changes are fundamentally incompatible (different approaches to the same problem). In that case:

1. Stop resolving line-by-line
2. Step back and decide which approach wins (or how to combine)
3. Possibly abort and redo one of the branches on top of the other from scratch
4. Talk to the other author if it's not your code

Forcing a textual resolution on a semantic conflict ships broken code.

## Verification After Resolving

- [ ] All conflict markers removed (`grep -rn '<<<<<<< ' .`)
- [ ] Files compile / type-check
- [ ] Tests pass
- [ ] Diff makes sense (`git diff HEAD`)
- [ ] No accidental dropped changes (compare to both sides)
