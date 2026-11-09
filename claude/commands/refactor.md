---
allowed-tools: Read, Bash, Grep, Glob, Skill
argument-hint: [file-path]
description: Intelligently refactor and improve code quality — systematic 17-step process grounded in SOLID, KISS, YAGNI, DRY and design patterns
---

# Intelligently Refactor and Improve Code Quality

Refactor the target: **$ARGUMENTS**

## Step 0 — Load Skills

Read the target, identify the language, then load skills accordingly:

| Language   | Skills to load                                        |
| ---------- | ----------------------------------------------------- |
| Go (`.go`) | `code-refactor` + `cc-skills-golang:golang-refactoring` |
| Other      | `code-refactor`                                        |

The `code-refactor` skill carries the detail this checklist only names: the code-smell and
SOLID-violation catalogue (`rules/diagnosis.md`), the named refactoring techniques with their
safe execution order (`references/refactoring-techniques.md`), GoF pattern selection and when
*not* to use a pattern (`rules/pattern-selection.md`), and the plan/report formats
(`templates/refactor-report.md`). Consult those rather than improvising equivalents.

If `$ARGUMENTS` is empty, ask which file or directory to refactor before starting. Refactoring
an unstated scope is how a focused change turns into a sprawling one.

## Workflow

This is the delivery sequence — what you produce, and in what order. The numbered Instructions
below are the coverage checklist for each stage; the pointers say which ones apply where.

1. **Diagnose the code** *(Instructions 1–2)*
   - Locate where SOLID principles are violated
   - Surface the latent code smells
   - Explain this code's responsibility and coupling problems

2. **Object-oriented analysis** *(Instructions 3)*
   - Run an OOA pass over the concepts in the original code — which latent objects or
     behaviors are hiding in there
   - Extract the classes and interfaces the functionality implies
   - Identify where a design pattern (GoF) genuinely belongs

3. **Refactoring proposal and pattern application** *(Instructions 3, 8)*
   - Apply suitable design patterns (Strategy, Factory, Observer, Decorator…)
   - For every proposal, state the reason and the improvement it targets — testability,
     decoupling, open-closed, single responsibility

4. **Architecture sketch of the result (UML class diagram)** *(Instructions 8)*
   - Provide a simple post-refactor UML class diagram showing object relationships and how
     responsibilities are divided

5. **Backward compatibility** *(Instructions 8)*
   - If the refactoring changes a public API or method signature, supply an Adapter or Wrapper
     so existing callers still compile
   - Mark the compatibility layer for future deprecation

6. **Refactored code** *(Instructions 5–6)*
   - Write complete, compilable code that follows SOLID and Clean Code, in the target's own
     language — Step 0 has already loaded the matching language skill
   - Modules must be named with clear semantics; `Helper`, `Impl`, `Util` and similar vague
     names are not acceptable

7. **Compare before and after** *(Instructions 15–16)*
   - Explain the gains in extensibility, testability, readability and dependency stability

8. **Regression testing** *(Instructions 11–14)*
   - Issue the test command and confirm every test still passes
   - If any test fails, fix the program logic — never delete or skip the test

## Instructions

Follow this systematic approach:

1. **Pre-Refactoring Analysis**
   - Identify the code that needs refactoring and the reasons why
   - Understand the current functionality and behavior completely
   - Diagnose concretely: which SOLID principles are violated and why (SRP, OCP, LSP, ISP, DIP)
   - Name the code smells present (God Object, Long Method, Feature Envy, Shotgun Surgery,
     Data Clumps, Primitive Obsession) and state the responsibility and coupling problems in
     plain language
   - Review existing tests and documentation
   - Identify all dependencies and usage points

2. **Test Coverage Verification**
   - Ensure comprehensive test coverage exists for the code being refactored
   - If tests are missing, write them BEFORE starting refactoring
   - Write characterization tests that pin down current behavior — including behavior that
     looks wrong. Refactoring preserves the present, it does not correct it
   - Run all tests to establish a baseline
   - Document current behavior with additional tests if needed

3. **Refactoring Strategy**
   - Define clear goals for the refactoring (readability, maintainability, testability)
   - Perform object-oriented analysis: which real-world concepts are tangled together, which
     classes/interfaces/value objects should be extracted, where the natural responsibility
     boundaries sit
   - Choose appropriate refactoring techniques:
     - Extract Method/Function
     - Extract Class/Component
     - Rename Variable/Method
     - Move Method/Field
     - Replace Conditional with Polymorphism
     - Eliminate Dead Code
   - Order them shallow-to-deep — rename and guard clauses first, type-structure changes last.
     The early moves usually reveal the correct seams for the later ones
   - Apply KISS: prefer the boring, obvious structure over the clever one
   - Apply YAGNI: no abstraction for a case that has occurred only once
   - Plan the refactoring in small, incremental steps

4. **Environment Setup**
   - Create a new branch: git checkout -b refactor/$ARGUMENTS
   - Ensure all tests pass before starting
   - Set up any additional tooling needed (profilers, analyzers)

5. **Incremental Refactoring**
   - Make small, focused changes one at a time
   - Run tests after each change to ensure nothing breaks
   - Commit working changes frequently with descriptive messages
   - Use IDE refactoring tools when available for safety
   - Never mix a behavior change into a refactoring commit — if the tests go red you must be
     able to attribute it to the restructuring alone

6. **Code Quality Improvements**
   - Improve naming conventions for clarity: name types by their responsibility, and avoid
     vague suffixes such as `Helper`, `Impl`, `Util`, `Manager`. If a name is hard to choose,
     the responsibility is not yet cleanly separated — go back to step 3
   - Eliminate code duplication (DRY principle), but stop short of forcing two things that
     merely look alike into one abstraction — if they change for different reasons, keep them apart
   - Simplify complex conditional logic
   - Reduce method/function length and complexity
   - Improve separation of concerns

7. **Performance Optimizations**
   - Identify and eliminate performance bottlenecks
   - Optimize algorithms and data structures
   - Reduce unnecessary computations
   - Improve memory usage patterns
   - Keep these in commits separate from the structural work, so a regression can be attributed

8. **Design Pattern Application**
   - Apply appropriate design patterns where beneficial (Strategy, Factory, Observer,
     Decorator, State, Adapter, Template Method…)
   - For each one, state the specific friction it removes and which principle it serves —
     "a switch-on-type in `ProcessPayment()` violates OCP because every new payment type edits
     the same function" is a reason; "this looks like a good fit for Strategy" is not
   - Do not introduce a pattern whose only justification is sophistication; indirection that
     buys nothing costs every future reader
   - Improve abstraction and encapsulation
   - Enhance modularity and reusability
   - Reduce coupling between components; depend on interfaces owned by the consumer, not on
     concrete types owned by the provider (DIP)
   - Sketch the resulting structure as a simple UML class diagram showing the new types,
     their relationships and their responsibilities
   - Preserve backward compatibility: if a public API or method signature changes, supply an
     Adapter or Wrapper so existing callers still compile, and mark that shim for later removal

9. **Error Handling Improvement**
   - Standardize error handling approaches
   - Improve error messages and logging
   - Add proper exception handling
   - Enhance resilience and fault tolerance
   - Like performance work, this changes behavior — keep it in its own commits

10. **Documentation Updates**
    - Update code comments to reflect changes
    - Revise API documentation if interfaces changed
    - Update inline documentation and examples
    - Ensure comments are accurate and helpful — a comment describing a structure that no
      longer exists is worse than no comment, because readers trust it

11. **Testing Enhancements**
    - Add tests for any new code paths created
    - Cover the new seams: extracted types and interfaces are now independently testable
    - Improve existing test quality and coverage
    - Remove or update obsolete tests — a test targeting logic that moved should be retargeted
      at its new public home rather than deleted
    - Restructuring test setup is fine; changing an assertion is not, because assertions are
      the behavioral contract that makes the refactoring verifiable
    - Ensure tests are still meaningful and effective

12. **Static Analysis**
    - Run linting tools to catch style and potential issues
    - Use static analysis tools to identify problems
    - Check for security vulnerabilities
    - Verify code complexity metrics

13. **Performance Verification**
    - Run performance benchmarks if applicable
    - Compare before/after metrics
    - Ensure refactoring didn't degrade performance
    - Document any performance improvements

14. **Integration Testing**
    - Run full test suite to ensure no regressions
    - Test integration with dependent systems — the callers catalogued in step 1 are the checklist
    - Verify all functionality works as expected
    - Test edge cases and error scenarios
    - If a test fails, fix the implementation; never delete or skip a test to get to green

15. **Code Review Preparation**
    - Review all changes for quality and consistency
    - Ensure refactoring goals were achieved
    - Compare before and after across extensibility, testability, readability and dependency
      stability, using concrete facts rather than adjectives — "required a Stripe sandbox to
      test" versus "inject a fake processor" is verifiable; "less coupled" is not
    - State the cost as well as the benefit: extra files, added indirection, compatibility
      shims left behind. A refactoring with no downside usually means the abstraction went too far
    - Prepare clear explanation of changes made
    - Document benefits and rationale

16. **Documentation of Changes**
    - Create a summary of refactoring changes
    - Document any breaking changes or new patterns
    - Update project documentation if needed
    - Explain benefits and reasoning for future reference

17. **Deployment Considerations**
    - Plan deployment strategy for refactored code
    - Consider feature flags for gradual rollout
    - Prepare rollback procedures
    - Set up monitoring for the refactored components

Remember: Refactoring should preserve external behavior while improving internal structure.
That constraint is not etiquette — it is what makes the work verifiable, because a green test
suite is the only proof that you changed structure and nothing else. Always prioritize safety
over speed, and maintain comprehensive test coverage throughout the process.
