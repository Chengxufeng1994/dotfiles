---
name: testing-strategy
description: |
  Design language-agnostic test strategies, test plans, and coverage-gap audits — decide
  WHAT to test, at which level (unit/integration/e2e), and in what order, before any tests
  get written. Reach for this when someone is planning how to test a feature, service, or
  refactor, or asking where their coverage is weak — "how should we test this", "what tests
  do we need", "test plan for X", "what are we missing", "where do I start testing this" —
  even if they never say the word "strategy". NOT for writing or fixing a specific test,
  debugging a failing test, test tooling/CI setup, or security/performance review: this
  skill produces the plan, then hands off to a language-specific testing or TDD skill for
  the mechanics.
---

# Testing Strategy

Decide *what* to test before *how*. The job of this skill is to turn a feature, change,
or existing codebase into a **prioritized test plan**: the right tests at the right
level, focused on what can actually break. It stops at the plan — writing the tests is
the job of the language-specific testing skill or your TDD workflow.

## Why a strategy first

Most weak test suites fail the same way: uniform effort everywhere. Trivial getters get
the same attention as the payment path; everything is a slow end-to-end test; or
coverage is 90% but the risky branch has none. A strategy fixes this by spending the
testing budget where failure is most likely and most costly — and saying out loud what
you chose *not* to test.

## Procedure

1. **Gather context.** What's the change or system? What breaks if it's wrong (data
   loss, money, security, silent corruption, user trust)? Who/what depends on it? If
   this is unclear, ask — a strategy built on a guessed blast radius is worthless.
2. **Map the surface.** List the units of behavior: entry points, branches, state
   transitions, external boundaries (DB, network, filesystem, time, randomness).
3. **Rank by risk.** Risk = likelihood of breaking × cost if it does. Business-critical
   paths, error handling, edge cases, security/permission boundaries, and data
   integrity rank highest. This ordering *is* the strategy — make it explicit.
4. **Pick a level per item** using the pyramid below. Default to the cheapest level that
   gives real confidence; reserve slow tests for flows that only break in integration.
5. **Write the plan** using the output template. Name concrete cases, not "test the
   happy path." Always include the gaps you're deliberately leaving.
6. **Pressure-test for completeness before finalizing.** The coverage table is a floor,
   not a ceiling — a fixed structure tempts you to fill the rows and stop. Ask: *what is
   the single highest-risk case not yet listed?* For security-sensitive components,
   sweep the canonical attack classes — auth bypass, token replay/forgery/expiry,
   injection, enumeration and timing leaks, privilege escalation, secrets in logs —
   before you decide what is safe to skip. Add what that surfaces, *then* write the
   "won't test" section.

## The pyramid (a tool, not a quota)

```
        /  E2E  \         Few — slow, brittle, highest confidence. Critical user journeys only.
       / Integration \    Some — real boundaries (DB, HTTP, queues). Where units meet.
      /   Unit Tests  \   Many — fast, isolated, focused. Business logic and edge cases.
```

Push tests *down* the pyramid when you can: if a bug is provable with a unit test, don't
spend an e2e on it. Push *up* only when the failure genuinely lives at the seam between
components. The shape is a guideline — a data pipeline or a pure library will have a
different profile than a web app, and that's fine.

## Strategy by component type

- **API / service endpoints** — unit-test the business logic; integration-test the
  transport + serialization layer; contract-test anything other teams consume.
- **Data pipelines / transforms** — input validation, transformation correctness,
  idempotency, and behavior on malformed/partial data.
- **UI / frontend** — component behavior and interaction; visual regression and
  accessibility for anything user-facing; reserve e2e for the few journeys that matter.
- **Infrastructure / config** — smoke tests, health checks, and load/chaos tests for
  anything in the critical path.
- **Pure logic / libraries** — heavy unit coverage including property-based or
  table-driven cases; little or no integration layer needed.

## What to cover vs. skip

**Cover:** business-critical paths, every error/exception branch, boundary values
(empty, max, off-by-one, unicode, timezone), security and authorization boundaries,
concurrency and ordering where it matters, and anything a past bug touched.

**Skip (and say so):** trivial getters/setters, framework/library internals, generated
code, one-off scripts, and pure pass-through wiring. Testing these inflates coverage
numbers without buying confidence.

## Output template

Produce the plan in this shape so it's scannable and hands off cleanly to implementation:

```markdown
# Test Plan: <feature / component>

## Risk summary
<1–3 sentences: what breaks if this is wrong, and the worst case.>

## Coverage plan
| Area / behavior | Level | Priority | Key cases |
|-----------------|-------|----------|-----------|
| <behavior>      | unit  | high     | <happy, <edge>, <error>> |
| ...             | ...   | ...      | ... |

## Existing gaps        (only when auditing an existing suite)
- <untested risky path> → recommend <level> test for <case>
- <brittle/implementation-coupled test> → why it's weak + fix

## Explicitly not testing
- <area> — <reason it's low-risk / out of scope>

## Suggested order
1. <highest risk × lowest cost first>
2. ...
```

## Hand-off

Once the plan is set, switch to the relevant language/framework testing skill or rules
for the actual implementation (e.g. `golang-testing`, the `ecc/*-testing` skills, or
`test-driven-development`). A good test *plan* states intent — *why* each case matters —
so the implementer writes tests that fail when the behavior regresses, not just tests
that pass today.
