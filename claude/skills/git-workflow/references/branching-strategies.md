# Branching Strategies

Three workflows dominate. Pick by team size and release cadence, not by what's trendy.

## GitHub Flow (Default Recommendation)

The simplest workflow that actually works. Best for SaaS, web apps, and most small-to-medium teams.

```
main (protected, always deployable)
  │
  ├── feature/user-auth      → PR → review → merge to main → deploy
  ├── feature/payment-flow   → PR → review → merge to main → deploy
  └── fix/login-bug          → PR → review → merge to main → deploy
```

**Rules:**
- `main` is always deployable. Protect it.
- Branch from `main` for any work.
- Open a PR when ready for review (even WIP, marked as draft).
- After approval and CI green, merge to `main`.
- Deploy immediately or on the next scheduled push.

**Why it works:** One source of truth (`main`), short feedback loops, no synchronization overhead between long-lived branches.

## Trunk-Based Development

Best for teams of 5+ experienced devs with strong CI/CD and feature flag infrastructure.

```
main (trunk)
  │
  ├── short-lived branch (1-2 days max, often hours)
  ├── short-lived branch
  └── short-lived branch
```

**Rules:**
- Everyone commits to `main` or branches that live for a day at most.
- Incomplete features hide behind feature flags.
- CI must be fast and reliable (under 10 minutes).
- Deploy continuously — multiple times per day is normal.

**Why it works:** Eliminates merge hell entirely. Forces small, incremental change. Requires discipline and infrastructure investment.

**Prerequisites before adopting:**
- Feature flag system (LaunchDarkly, GrowthBook, homegrown)
- Fast CI (<10 min) with high test reliability
- Trunk-based culture — pair programming or fast async review
- Comfort shipping unfinished code behind flags

## GitFlow

Best for enterprise products with scheduled releases, regulated industries (finance, healthcare, embedded), and multi-version support.

```
main (production releases — tagged versions only)
  │
  └── develop (integration branch)
        │
        ├── feature/user-auth        → merge to develop
        ├── feature/payment          → merge to develop
        │
        ├── release/1.2.0           → stabilize → merge to main + develop → tag
        │
        └── hotfix/critical-bug     → merge to main + develop → tag patch
```

**Rules:**
- `main` contains only production releases (tagged versions).
- `develop` is the integration branch — work merges here first.
- Feature branches from `develop`, back to `develop`.
- Release branches stabilize before going to `main`.
- Hotfixes branch from `main`, merge to both `main` and `develop`.

**Why teams pick it:** Clear separation of "what's in production" vs "what's coming". Supports parallel maintenance of multiple released versions.

**Why most teams don't need it:** Heavy synchronization cost. Slow feedback. Long-lived `develop` accumulates drift.

## Decision Matrix

| Question | GitHub Flow | Trunk-Based | GitFlow |
|----------|-------------|-------------|---------|
| Team size | Any | 5+ | 10+ |
| Releases per week | 1-many | Many per day | Scheduled (monthly/quarterly) |
| Feature flags available? | Optional | Required | Optional |
| CI duration | Any | <10 min | Any |
| Multiple supported versions? | No | No | Yes |
| Regulated industry? | No | No | Often |
| Best default? | **Yes** | Advanced | Specialized |

## Adoption Checklist

When introducing a workflow to a team:

- [ ] Document the chosen workflow in `CONTRIBUTING.md` with a diagram
- [ ] Protect `main` (and `develop` if GitFlow) — require PR reviews
- [ ] Configure required status checks (CI, lint, tests)
- [ ] Decide squash-merge vs merge-commit vs rebase-merge policy
- [ ] Set branch naming convention (feature/, fix/, etc.)
- [ ] Pick branch-deletion policy (auto-delete on merge recommended)
- [ ] Decide on PR template (defer to `pull-request-convention`)

## Anti-Patterns

- **Long-lived `develop` parallel to `main`** when releases are continuous → just use GitHub Flow.
- **Feature branches living >1 week** without rebasing → forced merge hell later.
- **GitFlow on a 3-person team** → ceremony cost exceeds benefit.
- **Trunk-based without feature flags** → broken main, scared deployers.
- **No protection on `main`** → someone *will* force-push or commit directly.
