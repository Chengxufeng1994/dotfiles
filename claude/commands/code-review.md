---
allowed-tools: Read, Bash, Grep, Glob
argument-hint: [file-path] | [commit-hash] | --full
description: Comprehensive code review including security, architecture, performance, and maintainability
---

# Code Review

Perform a comprehensive security, architecture, and quality review of the target code.

## 1. Determine Review Target

- Remote PR: If the user provides a PR number or URL (e.g., "Review PR #123"), target that remote PR.
- Local Changes: If no specific PR is mentioned, or if the user asks to "review my changes", target the current local file system states (staged and unstaged changes).

## 2. Preparation

- For Remote PR:
  1.  Checkout: Use the GitHub CLI to checkout the PR.
  2.  Fetch Changes: Ensure you have the latest changes from the PR branch.
- For Local Changes:
  1.  Identify Changes:
      - Check Git status: git status --porcelain
      - Recent commits: git diff --stat HEAD~5
      - Repository info: git log --oneline -5
      - Get changed files: git diff --name-only HEAD
      - Read diffs: git diff (working tree) and/or git diff --staged (staged).

## 3. In-Depth Analysis

Analyze the code changes based on the following pillars:

- Correctness: Does the code achieve its stated purpose without bugs or logical errors?
- Maintainability: Is the code clean, well-structured, and easy to understand and modify in the future? Consider factors like code clarity, modularity, and adherence to established design patterns.
- Readability: Is the code well-commented (where necessary) and consistently formatted according to our project's coding style guidelines?
- Efficiency: Are there any obvious performance bottlenecks or resource inefficiencies introduced by the changes?
- Security: Are there any potential security vulnerabilities or insecure coding practices?
- Edge Cases and Error Handling: Does the code appropriately handle edge cases and potential errors?
- Testability: Is the new or modified code adequately covered by tests (even if preflight checks pass)? Suggest additional test cases that would improve coverage or robustness.'

For each changed file, check for:

### Correctness

Determine whether the code achieves its intended behavior without bugs.

Check for:

- Incorrect conditions
- Race conditions
- Missing error propagation
- Incorrect business logic

---

### Security

Check for security vulnerabilities and unsafe practices.

Examples:

- Hardcoded credentials, API keys, tokens
- SQL injection
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks
- Authentication or Authorization flaws
- Unsafe deserialization
- Examine input validation and sanitization

---

### Performance

Identify performance bottlenecks.

Check for:

- Inefficient algorithms or database queries
- N+1 database queries
- Unnecessary memory allocations and potential leaks
- Blocking operations
- Large loops or heavy computations

---

### Architecture & Design

Evaluate architectural design and modularity.

Check for:

- Code Organization
- Separation of concerns
- Dependency direction
- Modular boundaries
- Tight coupling
- Layer violations

---

### Code Quality

Evaluate maintainability and readability.

Check for:

- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- console.log statements
- TODO/FIXME comments
- Missing JSDoc for public APIs
- Code duplication
- Naming clarity
- Overly complex logic
- Deep nesting
- Large functions

---

### Testing

Evaluate test coverage and test design.

Check for:

- Missing tests for new code
- Weak assertions
- Lack of edge case testing
- Missing failure scenario tests

---

### Documentation

Review documentation quality.

Check for:

- Missing API documentation
- Missing comments for complex logic
- Outdated README

---

## 4. Issue Classification

Every issue must be classified by severity.

---

### Security Issues (CRITICAL)

Issues that introduce security vulnerabilities or data integrity risks.

Examples:

- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks
- Authentication bypass
- Sensitive data exposure

CRITICAL issues must **block the commit or merge**.

---

### Code Quality Issues (HIGH)

Issues that may cause runtime bugs, reliability problems, or production failures.

Examples:

- Functions longer than 50 lines
- Files larger than 800 lines
- Nesting depth greater than 4 levels
- Missing error handling
- console.log statements
- TODO or FIXME comments
- Missing documentation for public APIs

HIGH issues should **require changes before approval**.

---

### Best Practice Issues (MEDIUM)

Issues related to maintainability and engineering best practices.

Examples:

- Mutation patterns where immutability would be safer
- Missing tests for new code
- Accessibility issues (a11y)
- duplicate logic
- minor architectural improvements

MEDIUM issues are **recommended improvements**.

---

### Minor Issues (LOW)

Minor style or readability improvements.

Examples:

- formatting inconsistencies
- naming suggestions
- comment improvements

LOW issues do not block approval.

---

## 5. Issue Report Format

Each issue must be reported using the following structure.

Severity: CRITICAL | HIGH | MEDIUM | LOW  
File: <file path>  
Line: <line number>

Issue  
<description of the issue>

Explanation  
<why this is a problem>

Suggested Fix  
<recommended fix or improvement>

---

## 6. Provide Detailed Feedback

Structure:

- Summary: A high-level overview of the review.
- Findings:
  - Critical: Bugs, security issues, or breaking changes.
  - Improvements: Suggestions for better code quality or performance.
  - Nitpicks: Formatting or minor style issues (optional).
- Conclusion: Clear recommendation (Approved / Request Changes).

Tone:

- Be constructive, professional, and friendly.
- Explain why a change is requested.
- For approvals, acknowledge the specific value of the contribution.

Generate report with: (##5. Issue Report Format)

- Severity: CRITICAL, HIGH, MEDIUM, LOW
- File location and line numbers
- Issue description
- Suggested fix

---

### Summary

Provide a high-level overview including:

- overall code quality
- security posture
- architectural observations

---

### Findings

Group issues by severity.

CRITICAL  
HIGH  
MEDIUM  
LOW

---

### Conclusion

Final recommendation:

APPROVED  
APPROVED WITH COMMENTS  
REQUEST CHANGES  
BLOCKED

Decision rules:

CRITICAL issues → BLOCKED  
HIGH issues → REQUEST CHANGES  
MEDIUM issues → APPROVED WITH COMMENTS  
LOW issues → APPROVED

---

# 7. Merge Policy

If CRITICAL or HIGH issues are detected:

Block commit or merge.

Never approve code that contains security vulnerabilities.
