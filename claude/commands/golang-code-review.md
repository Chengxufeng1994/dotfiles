---
allowed-tools: Agent
argument-hint: [file-path] | [PR-number] | --staged
description: Go code review — dispatches golang-code-reviewer agent to perform a comprehensive review of Go changes
---

Use the Agent tool with `subagent_type: golang-code-reviewer` and the following prompt:

```
Review target: $ARGUMENTS

If no target is specified, review all Go changes against main:
  git log main...HEAD --oneline
  git diff main...HEAD -- '*.go'

Include all commits and staged changes. Report findings grouped by severity.
```
