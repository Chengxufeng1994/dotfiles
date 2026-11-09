# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| code-architect | Feature architecture blueprints | Designing a feature against existing patterns |
| code-explorer | Trace existing features | Understanding code before changing it |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| test-engineer | Test strategy and test writing | New features, bug fixes |
| code-refactor-master | Refactoring and reorganization | Restructuring code |
| backend-developer | APIs, services, backend systems | Server-side implementation |
| microservices-architect | Distributed system design | Service decomposition |
| database-architect | Data modeling, database selection | Database design decisions |
| database-reviewer | PostgreSQL queries and schemas | Writing SQL or migrations |
| go-reviewer | Go code review | Go projects |
| go-build-resolver | Fix Go build and vet errors | When a Go build fails |
| typescript-reviewer | TypeScript/JavaScript code review | TypeScript/JavaScript projects |
| build-error-resolver | Fix TypeScript build and type errors | When a TypeScript build fails |
| python-reviewer | Python code review | Python projects |
| docs-lookup | Look up library docs through Context7 | Library, framework or API questions |
| env-var-detective | Env var and config drift | Undefined or mismatched env vars |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests - Use **planner** agent
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **test-engineer** agent
4. Architectural decision - Use **architect** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Delegation Completion Contract

Applies to every agent at every depth (parent, child, grandchild):

1. **Your final message IS the deliverable.** Never end your turn with "waiting for background agents" — a spawned task is not a completed task. Ending your turn while children are running orphans their results (completed children cannot notify a parent whose turn has ended).
2. **If you delegate, you own collection.** Wait for results, integrate them, then return. Fire-and-forget delegation is forbidden.
3. **Decompose only when the work cannot fit in one context.** Do not re-delegate a task already sized for a single agent — depth is an outcome, not a plan.

> Rationale: observed failure mode — research agents followed "Parallel Task Execution" above, spawned children, and returned "waiting" as their final answer. All children completed successfully but their results were orphaned. The parallel rule without a completion contract produces zombie tasks.

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
