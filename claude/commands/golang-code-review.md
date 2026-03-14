---
allowed-tools: Agent
argument-hint: [file-path] | [PR-number] | --staged
description: Go code review — dispatches golang-code-reviewer agent to perform a comprehensive review of Go changes
---

Use the subagent `subagent_type: golang-code-reviewer` to examine all of the changes by comparing them to the main branch. You must verify that every commit and stage on this branch is present, compare them to the main branch, and report back to me the review's outcome.
and the following prompt

```
Review target: $ARGUMENTS

If no target is specified, review all Go changes against main:
  git log main...HEAD --oneline
  git diff main...HEAD -- '*.go'

Include all commits and staged changes. Report findings grouped by severity.
```
