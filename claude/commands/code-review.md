---
allowed-tools: Read, Bash, Grep, Glob
argument-hint: [file-path] | [commit-hash] | --full
description: Comprehensive code review with security, performance, and architecture analysis
---

# Code Review

Comprehensive security and quality review of uncommitted changes:

1. Determine Review Target
   - Remote PR: If the user provides a PR number or URL (e.g., "Review PR #123"), target that remote PR.
   - Local Changes: If no specific PR is mentioned, or if the user asks to "review my changes", target the current local file system states (staged and unstaged changes).

2. Preparation
   - For Remote PR:
     1. Checkout: Use the GitHub CLI to checkout the PR.
     2. Fetch Changes: Ensure you have the latest changes from the PR branch.
   - For Local Changes:
     1. Identify Changes:
        - Check status: git status
        - Get changed files: git diff --name-only HEAD
        - Read diffs: git diff (working tree) and/or git diff --staged (staged).

3. In-Depth Analysis

Analyze the code changes based on the following pillars:

- Correctness: Does the code achieve its stated purpose without bugs or logical errors?
- Maintainability: Is the code clean, well-structured, and easy to understand and modify in the future? Consider factors like code clarity, modularity, and adherence to established design patterns.
- Readability: Is the code well-commented (where necessary) and consistently formatted according to our project's coding style guidelines?
- Efficiency: Are there any obvious performance bottlenecks or resource inefficiencies introduced by the changes?
- Security: Are there any potential security vulnerabilities or insecure coding practices?
- Edge Cases and Error Handling: Does the code appropriately handle edge cases and potential errors?
- Testability: Is the new or modified code adequately covered by tests (even if preflight checks pass)? Suggest additional test cases that would improve coverage or robustness.'

For each changed file, check for:

- **Security Issues (CRITICAL):**
  - Hardcoded credentials, API keys, tokens
  - SQL injection vulnerabilities
  - XSS vulnerabilities
  - Missing input validation
  - Insecure dependencies
  - Path traversal risks

- **Code Quality (HIGH):**
  - Functions > 50 lines
  - Files > 800 lines
  - Nesting depth > 4 levels
  - Missing error handling
  - console.log statements
  - TODO/FIXME comments
  - Missing JSDoc for public APIs

- **Best Practices (MEDIUM):**
  - Mutation patterns (use immutable instead)
  - Emoji usage in code/comments
  - Missing tests for new code
  - Accessibility issues (a11y)

4. Provide Detailed Feedback

Structure

- Summary: A high-level overview of the review.
- Findings:
  - Critical: Bugs, security issues, or breaking changes.
  - Improvements: Suggestions for better code quality or performance.
  - Nitpicks: Formatting or minor style issues (optional).
- Conclusion: Clear recommendation (Approved / Request Changes).

Tone

- Be constructive, professional, and friendly.
- Explain why a change is requested.
- For approvals, acknowledge the specific value of the contribution.

Generate report with:

- Severity: CRITICAL, HIGH, MEDIUM, LOW
- File location and line numbers
- Issue description
- Suggested fix

5. Block commit if CRITICAL or HIGH issues found

Never approve code with security vulnerabilities!
