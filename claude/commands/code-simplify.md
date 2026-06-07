---
description: Simplify code for clarity and maintainability — reduce complexity without changing behavior
---

# Code Simplify

**Guiding principle: clarity over cleverness.** Prefer the obvious, boring solution a reviewer can follow in six months over the compact, clever one. Never trade readability for line count, and never change observable behavior in the name of "simpler."

Invoke the agent-skills:code-simplification skill.

Simplify recently changed code (or the scope named in `$ARGUMENTS`) while preserving exact behavior:

1. Read CLAUDE.md and study project conventions
2. Identify the target code — recent changes unless `$ARGUMENTS` names a broader scope
3. Understand the code's purpose, callers, edge cases, and test coverage before touching it
4. Scan for simplification opportunities:
   - Deep nesting → guard clauses or extracted helpers
   - Long functions → split by responsibility
   - Nested ternaries → if/else or switch
   - Generic names → descriptive names
   - Duplicated logic → shared functions
   - Dead code → remove after confirming
5. Apply each simplification incrementally — run tests after each change
6. Verify all tests pass, the build succeeds, and the diff is clean

If tests fail after a simplification, revert that change and reconsider. Use `code-review-and-quality` to review the result.
