# Generic Pattern Catalogue

Worked implementations. Read `SKILL.md` first — several patterns people reach for here are already in the stdlib, and the gate there decides whether a type parameter belongs at all.

## Basic Type Parameters

```go
// Multiple type parameters. Map has no stdlib equivalent — Go cannot express
// it over iterators without allocating, so this one genuinely needs writing.
func Map[T, U any](slice []T, fn func(T) U) []U {
    result := make([]U, len(slice))
    for i, v := range slice {
        result[i] = fn(v)
    }
    return result
}

func Filter[T any](slice []T, predicate func(T) bool) []T {
    result := make([]T, 0, len(slice))
    for _, v := range slice {
        if predicate(v) {
            result = append(result, v)
        }
    }
    return result
}

func Reduce[T, U any](slice []T, initial U, fn func(U, T) U) U {
    acc := initial
    for _, v := range slice {
        acc = fn(acc, v)
    }
    return acc
}

// Usage — U is inferred from the function literal's return type.
nums := []int{1, 2, 3}
doubled := Map(nums, func(n int) int { return n * 2 })
labels := Map(nums, func(n int) string { return strconv.Itoa(n) })
sum := Reduce(nums, 0, func(acc, n int) int { return acc + n })
```

## Constraints

Import `cmp` from the stdlib (Go 1.21+). Reach for `golang.org/x/exp/constraints` only when you need `constraints.Integer`/`Float`/`Complex`, which have no stdlib equivalent — `constraints.Ordered` does not count, `cmp.Ordered` replaces it.

```go
import "cmp"

// Union constraint. Note the ~ — without it, `type Celsius float64` is rejected.
type Number interface {
    ~int | ~int8 | ~int16 | ~int32 | ~int64 |
    ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
    ~float32 | ~float64
}

func Sum[T Number](numbers []T) T {
    var total T          // zero value of T — works for every numeric type
    for _, n := range numbers {
        total += n
    }
    return total
}

func Abs[T Number](n T) T {
    if n < 0 {
        return -n
    }
    return n
}

// Method constraint. Before writing this, check whether a plain
// `func PrintAll(items []fmt.Stringer)` would do — usually it would.
// The type parameter earns its place only if you need to preserve T.
func PrintAll[T fmt.Stringer](items []T) {
    for _, item := range items {
        fmt.Println(item.String())
    }
}

// cmp.Ordered for operator-based comparison. Prefer it to constraints.Ordered.
func ClampAll[T cmp.Ordered](values []T, lo, hi T) []T {
    return Map(values, func(v T) T { return min(max(v, lo), hi) })
}
```

## Generic Containers

The clearest justified use: the element type is fixed at construction and preserved on the way out.

```go
type Stack[T any] struct {
    items []T
}

func NewStack[T any]() *Stack[T] {
    return &Stack[T]{items: make([]T, 0)}
}

func (s *Stack[T]) Push(item T) {
    s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T       // the idiom for "zero value of an unknown type"
        return zero, false
    }
    item := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return item, true
}

func (s *Stack[T]) Len() int { return len(s.items) }

// Usage
intStack := NewStack[int]()
intStack.Push(1)

stringStack := NewStack[string]()
stringStack.Push("hello")
```

Two-parameter containers follow the same shape; constrain the key with `comparable` so it can index a map:

```go
type Cache[K comparable, V any] struct {
    mu    sync.RWMutex
    items map[K]V
}

func NewCache[K comparable, V any]() *Cache[K, V] {
    return &Cache[K, V]{items: make(map[K]V)}
}

func (c *Cache[K, V]) Get(key K) (V, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    v, ok := c.items[key]
    return v, ok
}
```

## Pair and Result

```go
type Pair[T, U any] struct {
    First  T
    Second U
}

func NewPair[T, U any](first T, second U) Pair[T, U] {
    return Pair[T, U]{First: first, Second: second}
}

// A method cannot introduce new type parameters, but it can reorder the
// receiver's own — Pair[U, T] is a valid return type here.
func (p Pair[T, U]) Swap() Pair[U, T] {
    return Pair[U, T]{First: p.Second, Second: p.First}
}
```

```go
// Result carries a value or an error. Useful for fanning results out of
// goroutines; NOT a replacement for Go's `if err != nil` at call sites —
// idiomatic Go returns (T, error) and this fights that convention.
type Result[T any] struct {
    value T
    err   error
}

func Ok[T any](value T) Result[T]  { return Result[T]{value: value} }
func Err[T any](err error) Result[T] { return Result[T]{err: err} }

func (r Result[T]) IsOk() bool { return r.err == nil }

func (r Result[T]) Unwrap() (T, error) { return r.value, r.err }

func (r Result[T]) UnwrapOr(defaultValue T) T {
    if r.err != nil {
        return defaultValue
    }
    return r.value
}
```

## Generic Interfaces

```go
type Container[T any] interface {
    Add(item T)
    Remove() (T, bool)
    Len() int
}

type Queue[T any] struct {
    items []T
}

func (q *Queue[T]) Add(item T) {
    q.items = append(q.items, item)
}

func (q *Queue[T]) Remove() (T, bool) {
    if len(q.items) == 0 {
        var zero T
        return zero, false
    }
    item := q.items[0]
    q.items = q.items[1:]
    return item, true
}

func (q *Queue[T]) Len() int { return len(q.items) }

// A generic interface can be a parameter type like any other.
func Drain[T any](c Container[T]) []T {
    out := make([]T, 0, c.Len())
    for {
        item, ok := c.Remove()
        if !ok {
            return out
        }
        out = append(out, item)
    }
}
```

## Generic Channels

Fan-in and pipeline stages are the cleanest win: the body is identical for every element type, and `any` would force a cast on every receive.

```go
func Merge[T any](channels ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup

    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan T) {
            defer wg.Done()
            for v := range c {
                out <- v
            }
        }(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

func Stage[T, U any](in <-chan T, fn func(T) U) <-chan U {
    out := make(chan U)
    go func() {
        defer close(out)
        for v := range in {
            out <- fn(v)
        }
    }()
    return out
}

// Usage — the pipeline's element type changes at each stage and stays checked.
numbers := make(chan int)
doubled := Stage(numbers, func(n int) int { return n * 2 })
labels := Stage(doubled, strconv.Itoa)
```

These leak a goroutine if the consumer stops reading. Take a `context.Context` and select on `ctx.Done()` in anything long-lived.

## Union Constraints

```go
type Serializable interface {
    ~string | ~[]byte
}

// A conversion valid for every type in the set is valid for T. No switch needed.
func Serialize[T Serializable](data T) []byte {
    return []byte(data)
}
```

### The `any(data).(type)` trap

The version of this that circulates in tutorials reaches for a type switch, and it is **silently broken for named types**:

```go
func Serialize[T Serializable](data T) []byte {
    switch v := any(data).(type) {
    case string:
        return []byte(v)
    case []byte:
        return v
    default:
        panic("unreachable")   // ← reachable
    }
}

type UserID string
Serialize(UserID("u1"))   // panics: unreachable
```

`any(data)` boxes T's **dynamic** type, and a type switch matches that exactly — it does not fall back to the underlying type. `UserID` is not `string`, so it skips `case string:` and hits `default`. The `~` in the constraint governs which types satisfy the *constraint*; it has no effect on type-switch matching.

Verified on Go 1.26.5: the dynamic type reported is `main.UserID`.

Two ways out, in order of preference:

1. **Convert instead of switching**, as in the working version above. A conversion that is valid for every type in the type set is valid for `T`.
2. If the branches genuinely differ, switch on `reflect.TypeOf(data).Kind()` — `reflect.String` matches `UserID` — or accept that the type parameter is buying nothing and write two plain functions.

The `any(data).(type)` dance is generally the tell that the abstraction is thin: the type parameter buys only a compile-time restriction on callers. Sometimes that is worth it; once the switch grows a third arm with genuinely different logic, delete the type parameter.

## Superseded Recipes

These circulate widely in pre-1.21 Go generics tutorials. They still compile; do not write them in new code.

```go
func Max[T cmp.Ordered](a, b T) T          // → max(a, b) builtin, Go 1.21
func Contains[T comparable]([]T, T) bool    // → slices.Contains, Go 1.21
func Find[T comparable]([]T, T) (int, bool) // → slices.Index, Go 1.21
func Unique[T comparable]([]T) []T          // → slices.Sorted + slices.Compact
func Keys[K comparable, V any](map[K]V) []K // → slices.Collect(maps.Keys(m)), Go 1.23
```
