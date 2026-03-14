---
name: refactor-convention
description: Universal code refactoring conventions based on SOLID, KISS, YAGNI, DRY, and GoF design patterns. Load this skill whenever refactoring code in any language — it provides the shared workflow, principles, and pattern selection logic. Language-specific refactor skills (e.g. golang-refactor) build on top of this. Trigger when user says 'refactor', 'clean up', 'apply SOLID', 'code smells', 'god object', 'restructure', or shares code with mixed responsibilities or excessive coupling.
---

# Refactoring Convention

Universal refactoring workflow and principles for any language or framework.

## Principles (priority order)

1. **SOLID** — SRP, OCP, LSP, ISP, DIP
2. **KISS** — prefer boring and obvious over clever
3. **YAGNI** — don't add abstractions for hypothetical future needs
4. **DRY** — eliminate duplication, but don't over-abstract
5. **GoF patterns** — only when they genuinely reduce coupling or improve extensibility

## Step 0 — Establish a Safety Net

Before touching any code, confirm existing tests pass:

```bash
# run the project's test command
```

If tests are missing or broken, fix them first. Refactoring must not change observable behavior — tests are the only proof of that.

## Step 1 — Diagnose

Critically review the code and identify:

- Which SOLID principles are violated, and why
- Code smells: God Object, Long Method, Feature Envy, Shotgun Surgery, Data Clumps, Primitive Obsession, etc.
- Coupling and responsibility problems in plain language
- The impact now vs. as the codebase grows

## Step 2 — Object-Oriented Analysis

Identify the domain concepts hidden in the code:

- Which real-world concepts or behaviors are mixed together?
- What classes, interfaces, or value objects should be extracted?
- Where are the natural responsibility boundaries?
- Which structural frictions would a design pattern actually solve?

## Step 3 — Refactoring Plan

Propose a concrete plan:

- Which GoF patterns to apply and *why they fit* (not just which ones sound good)
- Which SOLID principle each change serves
- How backward compatibility is preserved for any public API changes — provide adapters or wrappers where needed, mark them for future deprecation

**Reasoning example:**
> Apply **Strategy** to the `switch-on-type` in `ProcessPayment()` — it violates OCP because adding a new payment type requires modifying the same function. Each Strategy encapsulates one payment algorithm, independently extensible without touching core logic.

## Step 4 — UML Class Diagram (simplified)

Show the new type relationships in text form:

```
┌─────────────────────┐        ┌───────────────────────┐
│ <<interface>>       │        │ ConcreteStrategy       │
│ PaymentProcessor    │◄──────│ CreditCardProcessor    │
│ + Process() error   │        │ + Process() error      │
└─────────────────────┘        └───────────────────────┘
```

Use `-->` (association), `..>` (dependency), `--|>` (inheritance), `..|>` (implementation).

## Step 5 — Refactored Code

Write complete, compilable code:

- Each type has a single, semantically clear responsibility
- No vague suffixes: no `Helper`, `Impl`, `Util`, `Manager`
- Dependencies injected via constructors
- Errors carry context
- No global state or singletons unless absolutely unavoidable
- Backward-compatible adapters/wrappers included where needed

## Step 6 — Before / After Comparison

| Dimension | Before | After |
|-----------|--------|-------|
| Testability | hard to mock | interface-based, freely mockable |
| Extensibility | requires modifying existing code | new types don't affect core |
| Readability | mixed responsibilities | one responsibility per file |
| Dependency stability | depends on concrete types | depends on stable interfaces |

## Step 7 — Verify

```bash
# regression tests
# static analysis (lint, vet, type check)
# benchmarks if performance-sensitive
```

- If any test fails, fix the implementation — never delete or skip tests
- Commit in small batches; each commit must compile and pass all tests

## Universal Rules

- Don't introduce abstractions for things that only happen once (YAGNI)
- Name types by their responsibility, not their role in the system
- Prefer composition over inheritance
- Interfaces belong in the consuming package, not the implementing one
