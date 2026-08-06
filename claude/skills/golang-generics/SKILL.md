---
name: golang-generics
description: Go type parameters and constraints — writing generic functions and types, choosing a constraint, and deciding whether a type parameter earns its place at all. Use when writing or reviewing code with `[T any]`, defining or selecting a constraint (comparable, cmp.Ordered, ~underlying types, unions), debugging type-inference or instantiation errors, or judging whether a generic abstraction beats an interface or plain duplication.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "2.0.0"
  origin: extracted from the golang-pro skill's generics reference
---

# Go Generics and Type Parameters

Generics arrived in Go 1.18. The language deliberately shipped them late and narrow, and the idiomatic bar for reaching for them is correspondingly high: **a type parameter has to buy something a plain interface or a duplicated function does not.**

## The Gate

Work through this before writing `[T any]`. Most code that reads as "this should be generic" should not be.

**Use a type parameter when:**

- The function body is **identical** across types and only the types differ — `slices.Index`, `maps.Clone`.
- You need to **preserve the caller's type** through the call. `func First[T any]([]T) T` returns `T`; the `any` version returns `any` and forces a cast at every call site.
- You are writing a **container** whose element type should be fixed at construction — `Stack[T]`, `Cache[K, V]`.
- The operation is on the **language's built-in operators** (`<`, `+`, `==`), which interfaces cannot express.

**Do not use a type parameter when:**

- **A method on an interface would do.** If the differing behaviour lives in the type, that is what interfaces are for. This is the single most common misuse.
- **You have exactly one instantiation.** Write it concretely. Make it generic on the *second* call site, not in anticipation of one.
- **The bodies differ per type.** A type switch inside a generic function means the abstraction is fake — you wrote a `switch` with extra syntax.
- **The stdlib already has it.** See below.

> Ian Lance Taylor's rule of thumb, from the Go team's own guidance: *write the concrete code first.* If duplicating it for a second type is mechanical, generalize then. If it isn't mechanical, generics were never the answer.

## Check the Stdlib First

Go 1.21 pulled `slices`, `maps`, and `cmp` into the standard library, and added the `min`/`max` builtins. Most hand-rolled generic helpers written before then are now dead weight:

| Hand-rolled | Use instead | Since |
|---|---|---|
| `func Max[T Ordered](a, b T) T` | `max(a, b)` builtin | 1.21 |
| `func Contains[T comparable]([]T, T) bool` | `slices.Contains` | 1.21 |
| `func Find[T comparable]([]T, T) (int, bool)` | `slices.Index` (returns -1) | 1.21 |
| `func Unique[T comparable]([]T) []T` | `slices.Sorted` + `slices.Compact` | 1.21 |
| `func Keys[K comparable, V any](map[K]V) []K` | `slices.Collect(maps.Keys(m))` | 1.23 |
| `func Values[K comparable, V any](map[K]V) []V` | `slices.Collect(maps.Values(m))` | 1.23 |
| custom `constraints.Ordered` | `cmp.Ordered` | 1.21 |

`maps.Keys` and `maps.Values` return an `iter.Seq`, not a slice — wrap with `slices.Collect` when you need one. There is **no stdlib `Map`/`Filter`/`Reduce`**; those genuinely need writing (or a library) because Go has no way to express them over iterators without allocating.

`golang.org/x/exp/constraints` still exists for `constraints.Integer`/`Float`/`Complex`, which have no stdlib equivalent. `constraints.Ordered` is superseded by `cmp.Ordered` — prefer the stdlib one and avoid the `x/exp` dependency when `cmp` suffices.

## Choosing a Constraint

Pick the loosest constraint that admits the operations you actually perform. Over-constraining is the quieter failure: it compiles for you and rejects a caller's perfectly valid type.

| Constraint | Admits | Reach for it when |
|---|---|---|
| `any` | every type | you only move values around — no operators, no methods |
| `comparable` | types supporting `==` and `!=` | map keys, equality checks, dedup |
| `cmp.Ordered` | numbers and strings | `<`, `>`, sorting, min/max |
| a method interface | types with those methods | behaviour differs per type — **and check whether a plain interface is enough** |
| a union (`int \| string`) | exactly the listed types | operators over a fixed, closed set |
| `~int` (approximate) | `int` **and** every named type whose underlying type is `int` | almost always — a bare `int` in a union silently excludes `type UserID int` |

**Use `~` by default in unions.** A constraint written `int | string` rejects `type Celsius float64`-style named types, which is virtually never what the author meant. Write `~int | ~string`.

## Type Inference

Inference works from the function's ordinary arguments, not its return type:

```go
result := Identity(42)        // T inferred as int
minVal := min(10, 20)         // builtin, T = int

// Inference fails: nothing in the arguments determines U
result := Map([]int{1, 2}, func(n int) string { return strconv.Itoa(n) })  // OK — U from the func literal
var zero := Zero[int]()       // explicit — no argument to infer from
```

When you hit `cannot infer T`, the fix is almost always to supply the type argument explicitly rather than to restructure the signature. Partial inference is allowed — `Map[int]` leaves `U` inferred.

## Quick Reference

| Feature | Syntax | Use case |
|---------|--------|----------|
| Basic generic | `func F[T any]()` | any type |
| Constrained | `func F[T cmp.Ordered]()` | restricted types |
| Multiple params | `func F[T, U any]()` | multiple type variables |
| Comparable | `func F[T comparable]()` | `==` / `!=`, map keys |
| Union | `interface{ ~int \| ~string }` | closed set of types |
| Approximate | `~int` | include named types with that underlying type |
| Generic type | `type Stack[T any] struct{ ... }` | containers |
| Method on generic type | `func (s *Stack[T]) Push(T)` | receivers restate the parameter |

Methods **cannot** introduce their own type parameters — only the type they hang off can. `func (s *Stack[T]) MapTo[U any]() Stack[U]` does not compile; make it a plain function.

## Pattern Catalogue

Worked implementations — generic containers, `Pair`/`Result`, generic interfaces, channel helpers, and union constraints — are in `references/patterns.md`.
