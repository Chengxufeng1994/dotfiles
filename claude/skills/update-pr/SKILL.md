---
name: update-pr
description: |
  Update an already-open GitHub pull request: refresh or edit its title and body, push new commits,
  address and resolve review feedback (review threads/conversations), and rebase it onto the base
  branch when it has fallen behind. Use this whenever the user wants to update, refresh, sync, revise,
  or bring up to date an existing PR — phrases like "update PR 123", "refresh my pull request",
  "edit the PR description", "address the review comments on #45", "resolve the review conversations",
  "my PR is behind main", or "sync the PR". A PR number is required. This is NOT for creating a new PR
  (use create-pr or create-detail-pr), nor for reviewing, merging, or summarizing a PR.
---

# Update Pull Request

Update an existing, already-open GitHub pull request. This skill is the counterpart to
`create-pr` / `create-detail-pr`: those open a PR, this one keeps it healthy after it exists.

It covers four kinds of update, and you run **only the phases the task actually needs** — most
updates touch one or two, not all of them:

- **Refresh title & body** — re-sync the description to the current state of the branch
- **Push new commits** — land outstanding work so the PR diff reflects it
- **Address review feedback** — fix what reviewers flagged, then resolve their threads
- **Sync with base** — rebase onto the base branch when the PR has fallen behind

## When to Use

- The user names a PR and wants it updated, refreshed, synced, or revised
- A PR's description has drifted from what the branch now contains
- Reviewers left comments that need fixes and thread resolution
- The PR is behind its base branch and needs to catch up
- Local commits exist that haven't been pushed to the PR branch

Do **not** use this to open a new PR — that's `create-pr` / `create-detail-pr`.

## Inputs

A **PR number is required** — this skill always operates on an explicitly named PR, never on
"whatever branch I'm on". If the user didn't give one, ask for it before doing anything. Working
on the wrong PR is hard to undo, so resolving ambiguity up front is worth the one question.

Throughout, `$PR` is that number.

## Phases

Each phase is conditional. Read the user's intent, run the phases that apply, skip the rest.
The ordering matters where phases depend on each other — in particular, **fixes must be pushed
before their review threads are resolved**, or you'll mark feedback done while the remote still
shows the old code.

### Phase 1 — Resolve the PR and check out its branch

Always run this first — you can't safely update what you haven't read.

```bash
gh pr view $PR --json number,title,body,headRefName,baseRefName,state,isDraft,mergeable,reviewDecision,url
gh pr checks $PR
```

- If `state` isn't `OPEN`, stop and tell the user — you don't update a merged or closed PR.
- Check out the PR's head branch locally so later phases act on the right code:

  ```bash
  gh pr checkout $PR
  ```

**Deliverable:** a clear picture of the PR's state (title, body, base, CI status, review decision,
unresolved threads) and a local checkout on its head branch.

### Phase 2 — Sync with the base branch (only if behind)

Run this when the PR has fallen behind its base, or the user asks to sync. **Rebase, don't merge** —
a merge commit from the base into a feature branch clutters history and makes the diff noisier for
reviewers.

```bash
git fetch origin $BASE          # BASE = baseRefName from Phase 1
git rebase origin/$BASE
```

If conflicts surface, resolve them at the root cause (don't blindly take one side), continue the
rebase, and re-run the branch's tests before moving on. A rebase rewrites history, so this branch
will need a force-push in Phase 4.

**Deliverable:** the head branch sits cleanly on top of the latest base, tests still green.

### Phase 3 — Address review feedback (only if there are unresolved threads)

Fetch the unresolved threads and make the requested fixes in code. Treat each thread as intent to
understand, not just text to satisfy — if a comment seems wrong, surface that rather than
silently complying.

List unresolved threads:

```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first: 5) { nodes { author { login } body } }
        }
      }
    }
  }
}' -F owner='OWNER' -F repo='REPO' -F pr=$PR
```

(Get `OWNER`/`REPO` from `gh repo view --json owner,name`.) Skip threads where `isResolved` is
already true. Make the fix for each remaining thread. Save the thread `id`s — you'll resolve them
in Phase 5, *after* the fixes are pushed.

**Deliverable:** code changes that genuinely address each open thread, committed locally.

### Phase 4 — Push

Push when there's anything new on the branch — fresh local commits, feedback fixes from Phase 3,
or a rebase from Phase 2.

Before pushing, make sure no one else advanced the branch while you worked:

```bash
git fetch origin $HEAD          # HEAD = headRefName from Phase 1
```

- **No rebase happened** → a normal push is safe:

  ```bash
  git push origin HEAD
  ```

- **You rebased in Phase 2** → you must force-push, but use `--force-with-lease` (never plain
  `--force`). The lease aborts the push if someone else pushed in the meantime, so you can't
  silently clobber their work:

  ```bash
  git push --force-with-lease origin HEAD
  ```

  If the lease rejects the push, someone pushed concurrently — fetch, rebase your work on top of
  theirs, and retry. Don't override the lease.

**Deliverable:** the remote PR branch reflects all intended changes.

### Phase 5 — Resolve review threads (only after Phase 3 fixes are pushed)

Now that the fixes are live on the PR, resolve each thread you addressed:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: { threadId: $threadId }) { thread { isResolved } }
}' -F threadId='THREAD_ID'
```

Optionally reply to a thread first to explain how you addressed it. Only resolve threads whose
feedback you actually handled — leaving a genuinely open question resolved misleads the reviewer.

**Deliverable:** every addressed thread is resolved; anything left open is intentional.

### Phase 6 — Refresh title & body (when the description has drifted)

When new commits have landed or the user asks for a refresh, bring the title and body back in line
with what the branch now contains.

**Load the `pull-request-convention` skill first** — it owns the title format rules and the body
principles. Don't restate or guess them.

Read every commit that will land, not just the latest:

```bash
git log origin/$BASE..HEAD --format="%h %s"
git diff origin/$BASE...HEAD
```

Then update the PR. Match whichever body shape it already uses (lean `create-pr` vs detailed
`create-detail-pr`) rather than reformatting wholesale:

```bash
gh pr edit $PR --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Keep the body focused on the **why**; the diff already shows the what. Delete any section that has
nothing real to say.

**Deliverable:** title passes the convention; body reflects the current state of the branch.

### Phase 7 — Verify and report

Don't claim success you haven't observed. Re-check the PR and report honestly:

```bash
gh pr view $PR --json mergeable,reviewDecision,url
gh pr checks $PR
```

If CI is still running, say so rather than implying it passed. If a check failed, surface it.

## Output Format

Report back what you actually did, per phase, in a short summary:

```markdown
## Updated PR #<number> — <title>

- **Synced with base**: <rebased onto origin/<base>, N conflicts resolved | skipped, already up to date>
- **Pushed**: <N commits | force-pushed after rebase | nothing to push>
- **Review feedback**: <N threads addressed and resolved | none open>
- **Title/body**: <refreshed | unchanged>
- **Checks**: <passing | running | M failing — names>

<PR URL>
```

Omit lines for phases you didn't run.

## Guardrails

These exist because the failure modes are costly and hard to reverse:

- **Always require an explicit PR number.** Acting on the wrong PR is the most expensive mistake
  here. If it's missing, ask.
- **Rebase, never merge the base in.** Keeps PR history linear and the diff clean for reviewers.
- **`--force-with-lease`, never `--force`.** The lease is what prevents silently overwriting a
  collaborator's concurrent push.
- **Push fixes before resolving their threads.** A resolved thread should always correspond to code
  that's actually live on the PR.
- **Report check status truthfully.** "Tests pass" is wrong if they're still running or any failed.
- **Only run the phases the task needs.** A title refresh shouldn't trigger a rebase; addressing one
  comment shouldn't rewrite the whole body.

## Examples

**Example 1 — address review feedback**
Input: "address the review comments on PR 142"
Phases run: 1 (resolve) → 3 (fix each thread) → 4 (push) → 5 (resolve threads) → 7 (verify).
Skips rebase and body refresh — nothing asked for them.

**Example 2 — PR fell behind main**
Input: "PR 88 is behind main, sync it"
Phases run: 1 → 2 (rebase onto origin/main) → 4 (force-push with lease) → 7.
Skips feedback and body refresh.

**Example 3 — full refresh after pushing work**
Input: "I pushed a bunch of new commits to PR 53, update the description"
Phases run: 1 → 6 (reload convention, rewrite title/body from the full diff) → 7.
No rebase, no force-push, no threads.
