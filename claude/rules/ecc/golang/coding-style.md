---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---
# Go Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Go specific content.

## Formatting

- **gofmt** and **goimports** are mandatory — no style debates

## Design Principles

- Accept interfaces, return structs
- Keep interfaces small (1-3 methods)

## Error Handling

Always wrap errors with context:

```go
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
```

## Reference

See skills: `golang-code-style` (gofmt, goimports, comment conventions),
`golang-naming` (identifier conventions), `golang-error-handling` (wrapping,
`errors.Is`/`As`, the single handling rule), and `golang-structs-interfaces`
(accept interfaces, return structs; interface segregation).
