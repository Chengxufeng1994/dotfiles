---
name: create-pr
description: Creates GitHub pull requests with properly formatted titles. Use when creating PRs, submitting changes for review, or when the user says /pr or asks to create a pull request.
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob
---

# Create Pull Request

Create GitHub pull requests with properly formatted titles and detailed descriptions.

## Steps

### 1. **Check current state**:

To get the latest staged changes and understand the context of your modifications.

```bash
git status
git diff --stat
git log origin/master..HEAD --oneline
```

Ensure:

- All changes are committed
- Branch is up to date with remote
- Changes are rebased on main if needed

### 2. **Analyze changes** to determine:

Review what will be included in the PR:

```bash
# See all commits that will be in the PR
git log main..HEAD

# See the full diff
git diff main...HEAD
```

Understand the scope and purpose of all changes before writing the description.

- Type: What kind of change is this?
- Scope: Which package/area is affected?
- Summary: What does the change do?

### 3. **Write the PR Description**

Follow this structure:

```markdown
<brief description of what the PR does>

<why these changes are being made - the motivation>

<alternative approaches considered, if any>

<any additional context reviewers need>
```

**Do NOT include:**

- "Test plan" sections
- Checkbox lists of testing steps
- Redundant summaries of the diff

**Do include:**

- Clear explanation of what and why
- Links to relevant issues or tickets
- Context that isn't obvious from the code
- Notes on specific areas that need careful review

Summarize the changes in this structure:

- **High-level summary**: one sentence describing the purpose of this change.
- **Key modifications**: bullet points grouped by file or functionality.
- **Impact analysis**: effect on APIs, authentication logic, database, performance, tests, or security.

### 4. Create a **Pull Request (PR)** draft that includes:

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
<description body here>
EOF
)"
```

#### PR Title Format

```
<type>(<scope>): <summary>
```

#### Types (required)

| Type       | Description                         | Changelog |
| ---------- | ----------------------------------- | --------- |
| `feat`     | New feature                         | Yes       |
| `fix`      | Bug fix                             | Yes       |
| `perf`     | Performance improvement             | Yes       |
| `test`     | Adding/correcting tests             | No        |
| `docs`     | Documentation only                  | No        |
| `refactor` | Code change (no bug fix or feature) | No        |
| `build`    | Build system or dependencies        | No        |
| `ci`       | CI configuration                    | No        |
| `chore`    | Routine tasks, maintenance          | No        |

#### PR Body Guidelines

- **Summary**:
  - Describe what the PR does
  - Explain why this change was made
- **Detailed change log**:
  - clear bullet-point list of the modifications
- **Security improvements**:
  - explicitly highlight how this change improves security
- **Testing information**:
  - explain how these changes were tested (unit tests, integration tests, manual validation, etc.)
- **Impact/Risks**:
  - list possible risks (security vulnerabilities, performance bottlenecks, breaking changes, maintainability issues)
- **Checklist**:
  - [ ] Unit tests added/updated
  - [ ] Integration tests updated
  - [ ] Documentation updated or follow-up ticket created
  - [ ] Backward compatibility checked
- **Related Links**:
  - Link to Linear ticket: `https://linear.app/n8n/issue/[TICKET-ID]`
  - Link to GitHub issues using keywords to auto-close:
    - `closes #123` / `fixes #123` / `resolves #123`
  - Link to Community forum posts if applicable

## Examples

### Feature in editor

```
feat(editor): Add workflow performance metrics display
```

### Bug fix in core

```
fix(core): Resolve memory leak in execution engine
```

### Node-specific change

```
fix(Slack Node): Handle rate limiting in message send
```

### Breaking change (add exclamation mark before colon)

```
feat(api)!: Remove deprecated v1 endpoints
```

### No changelog entry

```
refactor(core): Simplify error handling (no-changelog)
```

### No scope (affects multiple areas)

```
chore: Update dependencies to latest versions
```

## Validation

The PR title must match this pattern:

```
^(feat|fix|perf|test|docs|refactor|build|ci|chore|revert)(\([a-zA-Z0-9 ]+( Node)?\))?!?: [A-Z].+[^.]$
```

Key validation rules:

- Type must be one of the allowed types
- Scope is optional but must be in parentheses if present
- Exclamation mark for breaking changes goes before the colon
- Summary must start with capital letter
- Summary must not end with a period
