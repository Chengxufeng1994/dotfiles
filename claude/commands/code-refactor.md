---
allowed-tools: Read, Bash, Grep, Glob, Skill
argument-hint: [file-path]
description: Language-aware code refactoring — detects language and loads the appropriate refactoring skills
---

Refactor the target code: $ARGUMENTS

## Step 1 — Detect Language and Load Skills

Read the target file, identify the language, then load skills accordingly:

| Language   | Skills to load                              |
|------------|---------------------------------------------|
| Go (`.go`) | `refactor-convention` + `golang-pro`        |
| Other      | `refactor-convention`                       |

## Step 2 — Refactor

Follow the `refactor-convention` workflow (7 steps). Apply language-specific patterns from the loaded skill.
