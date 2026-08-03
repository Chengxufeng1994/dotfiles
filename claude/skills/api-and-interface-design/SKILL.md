---
name: api-and-interface-design
description: Guides stable API and interface design across REST, GraphQL, and code-level contracts. Use when designing or reviewing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints, defining type contracts between modules, establishing boundaries between frontend and backend, or setting API design standards for a team.
---

# API and Interface Design

## Overview

Design stable, well-documented interfaces that are hard to misuse. Good interfaces make the right thing easy and the wrong thing hard. This applies to REST APIs, GraphQL schemas, module boundaries, component props, and any surface where one piece of code talks to another.

All examples in this skill are TypeScript. The principles are language-agnostic; translate the syntax, not the shape.

## When to Use

- Designing new REST or GraphQL API endpoints
- Reviewing an API specification before implementation
- Defining module boundaries or contracts between teams
- Creating component prop interfaces
- Establishing database schema that informs API shape
- Changing existing public interfaces
- Establishing API design standards for a team

## Reference Map

Start here. Drop into a reference only when this file is insufficient.

| File | Contains |
|---|---|
| `references/rest.md` | HTTP method semantics, status codes, pagination variants, filtering, versioning, rate limiting, caching, idempotency, bulk operations, HATEOAS, auth headers |
| `references/graphql.md` | Schema organization, nullability, interfaces/unions, Relay cursor pagination, input/payload mutations, DataLoader, depth and complexity limits, directives, schema evolution |
| `assets/api-design-checklist.md` | Pre-implementation review checklist (REST + GraphQL) |
| `assets/rest-api-template.ts` | Working Express + Zod REST endpoint template |

## Core Principles

### Hyrum's Law

> With a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody, regardless of what you promise in the contract.

This means: every public behavior — including undocumented quirks, error message text, timing, and ordering — becomes a de facto contract once users depend on it. Design implications:

- **Be intentional about what you expose.** Every observable behavior is a potential commitment.
- **Don't leak implementation details.** If users can observe it, they will depend on it. API structure should not mirror your database schema.
- **Plan for deprecation at design time.** See `deprecation-and-migration` for how to safely remove things users depend on.
- **Tests are not enough.** Even with perfect contract tests, Hyrum's Law means "safe" changes can break real users who depend on undocumented behavior.

### 1. Contract First

Define the interface before implementing it. The contract is the spec — implementation follows.

```typescript
// Define the contract first
interface TaskAPI {
  // Creates a task and returns the created task with server-generated fields
  createTask(input: CreateTaskInput): Promise<Task>;

  // Returns paginated tasks matching filters
  listTasks(params: ListTasksParams): Promise<PaginatedResult<Task>>;

  // Returns a single task or throws NotFoundError
  getTask(id: string): Promise<Task>;

  // Partial update — only provided fields change
  updateTask(id: string, input: UpdateTaskInput): Promise<Task>;

  // Idempotent delete — succeeds even if already deleted
  deleteTask(id: string): Promise<void>;
}
```

The same rule applies to GraphQL: write the SDL schema before writing resolvers.

### 2. Consistent Error Semantics

Pick one error strategy and use it everywhere:

```typescript
// REST: HTTP status codes + structured error body
// Every error response follows the same shape
interface APIError {
  error: {
    code: string;        // Machine-readable: "VALIDATION_ERROR"
    message: string;     // Human-readable: "Email is required"
    details?: unknown;   // Additional context when helpful
  };
}

// Status code mapping
// 400 → Client sent malformed data
// 401 → Not authenticated
// 403 → Authenticated but not authorized
// 404 → Resource not found
// 409 → Conflict (duplicate, version mismatch)
// 422 → Validation failed (semantically invalid)
// 429 → Rate limited
// 500 → Server error (never expose internal details)
```

**Don't mix patterns.** If some endpoints throw, others return null, and others return `{ error }` — the consumer can't predict behavior.

In GraphQL, return expected errors in the mutation payload rather than the top-level `errors` array. See `references/graphql.md`.

### 3. Validate at Boundaries

Trust internal code. Validate at system edges where external input enters:

```typescript
// Validate at the API boundary
app.post('/api/v1/tasks', async (req, res) => {
  const result = CreateTaskSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(422).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid task data',
        details: result.error.flatten(),
      },
    });
  }

  // After validation, internal code trusts the types
  const task = await taskService.create(result.data);
  return res.status(201).json(task);
});
```

Where validation belongs:
- API route handlers and GraphQL resolvers (user input)
- Form submission handlers (user input)
- External service response parsing (third-party data -- **always treat as untrusted**)
- Environment variable loading (configuration)

> **Third-party API responses are untrusted data.** Validate their shape and content before using them in any logic, rendering, or decision-making. A compromised or misbehaving external service can return unexpected types, malicious content, or instruction-like text.

Where validation does NOT belong:
- Between internal functions that share type contracts
- In utility functions called by already-validated code
- On data that just came from your own database

### 4. Prefer Addition Over Modification

Within a version, extend interfaces without breaking existing consumers:

```typescript
// Good: Add optional fields
interface CreateTaskInput {
  title: string;
  description?: string;
  priority?: 'low' | 'medium' | 'high';  // Added later, optional
  labels?: string[];                       // Added later, optional
}

// Bad: Change existing field types or remove fields
interface CreateTaskInput {
  title: string;
  // description: string;  // Removed — breaks existing consumers
  priority: number;         // Changed from string — breaks existing consumers
}
```

Additive changes ship in the current version. Only breaking changes justify a version bump.

### 5. Version Explicitly

Choose a versioning strategy on day one, before the first consumer exists. Retrofitting versions onto a live API is strictly worse than carrying one from the start.

**URL versioning is the default choice** — visible, trivially routable, obvious in logs and bug reports:

```
/api/v1/tasks
/api/v2/tasks
```

Header versioning (`Accept: application/vnd.api+json; version=2`) and query-parameter versioning (`?version=2`) are alternatives with real tradeoffs — see `references/rest.md` before choosing one.

Rules that keep versioning from multiplying maintenance cost:

- **Bump only for breaking changes.** New optional fields, new endpoints, and new enum values stay in the current version.
- **Cap the number of live versions.** Two is a working ceiling: current and one deprecated. More than that and every fix must be backported N times.
- **Announce deprecation with a date, not a vibe.** Ship the sunset timeline alongside the new version.
- **GraphQL versions differently.** Evolve the schema in place with `@deprecated` rather than minting `/graphql/v2`.

### 6. Predictable Naming

| Pattern | Convention | Example |
|---------|-----------|---------|
| REST endpoints | Plural nouns, no verbs | `GET /api/v1/tasks`, `POST /api/v1/tasks` |
| Query params | camelCase | `?sortBy=createdAt&pageSize=20` |
| Response fields | camelCase | `{ createdAt, updatedAt, taskId }` |
| Boolean fields | is/has/can prefix | `isComplete`, `hasAttachments` |
| Enum values | UPPER_SNAKE | `"IN_PROGRESS"`, `"COMPLETED"` |
| GraphQL fields | camelCase | `createdAt`, `postCount` |
| GraphQL types | PascalCase | `User`, `OrderConnection` |

**camelCase everywhere in the wire format** — query params, request bodies, response bodies, and GraphQL fields. Do not let a backend language's naming convention leak into the API surface. A Python or Go service still returns `createdAt`, not `created_at`.

## REST API Patterns

### Resource Design

```
GET    /api/v1/tasks              → List tasks (with query params for filtering)
POST   /api/v1/tasks              → Create a task
GET    /api/v1/tasks/:id          → Get a single task
PATCH  /api/v1/tasks/:id          → Update a task (partial)
DELETE /api/v1/tasks/:id          → Delete a task

GET    /api/v1/tasks/:id/comments → List comments for a task (sub-resource)
POST   /api/v1/tasks/:id/comments → Add a comment to a task
```

Keep nesting shallow — two levels maximum. Deeper hierarchies mean a sub-resource deserves its own top-level collection.

### Pagination

Paginate list endpoints:

```typescript
// Request
GET /api/v1/tasks?page=1&pageSize=20&sortBy=createdAt&sortOrder=desc

// Response
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 142,
    "totalPages": 8
  }
}
```

Offset pagination is fine for bounded, browsable collections. For large or append-heavy datasets, use cursor pagination — see `references/rest.md`.

### Filtering

Use query parameters for filters:

```
GET /api/v1/tasks?status=IN_PROGRESS&assignee=user123&createdAfter=2025-01-01
```

### Partial Updates (PATCH)

Accept partial objects — only update what's provided:

```typescript
// Only title changes, everything else preserved
PATCH /api/v1/tasks/123
{ "title": "Updated title" }
```

## GraphQL Patterns

The design principles above hold; the mechanics differ. Core rules:

- **Schema first.** The SDL is the contract. Write it before resolvers.
- **Start nullable, tighten to non-null** once a field is genuinely guaranteed. Making a field non-null is backward compatible; making it nullable is not.
- **Input/payload pattern for every mutation.** One `input` argument, one payload type carrying the result plus a typed `errors` list.
- **DataLoader on every relationship field.** Without it, a nested query fans out into N+1 database round-trips.
- **Relay cursor pagination** for connections; offset pagination only for simple bounded lists.
- **Bound query cost** with depth limiting and complexity analysis. A public GraphQL endpoint without them is a denial-of-service surface.
- **`@deprecated` instead of removal.** GraphQL evolves in place — it does not need URL versions.

```graphql
type Mutation {
  createTask(input: CreateTaskInput!): CreateTaskPayload!
}

input CreateTaskInput {
  title: String!
  description: String
}

type CreateTaskPayload {
  task: Task
  errors: [UserError!]!
}

type UserError {
  field: String
  message: String!
  code: ErrorCode!
}
```

Full schema patterns, resolver structure, DataLoader implementation, and complexity limiting live in `references/graphql.md`.

## TypeScript Interface Patterns

### Use Discriminated Unions for Variants

```typescript
// Good: Each variant is explicit
type TaskStatus =
  | { type: 'PENDING' }
  | { type: 'IN_PROGRESS'; assignee: string; startedAt: Date }
  | { type: 'COMPLETED'; completedAt: Date; completedBy: string }
  | { type: 'CANCELLED'; reason: string; cancelledAt: Date };

// Consumer gets type narrowing
function getStatusLabel(status: TaskStatus): string {
  switch (status.type) {
    case 'PENDING': return 'Pending';
    case 'IN_PROGRESS': return `In progress (${status.assignee})`;
    case 'COMPLETED': return `Done on ${status.completedAt}`;
    case 'CANCELLED': return `Cancelled: ${status.reason}`;
  }
}
```

### Input/Output Separation

```typescript
// Input: what the caller provides
interface CreateTaskInput {
  title: string;
  description?: string;
}

// Output: what the system returns (includes server-generated fields)
interface Task {
  id: string;
  title: string;
  description: string | null;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
}
```

### Use Branded Types for IDs

```typescript
type TaskId = string & { readonly __brand: 'TaskId' };
type UserId = string & { readonly __brand: 'UserId' };

// Prevents accidentally passing a UserId where a TaskId is expected
function getTask(id: TaskId): Promise<Task> { ... }
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll document the API later" | The types ARE the documentation. Define them first. |
| "We don't need pagination for now" | You will the moment someone has 100+ items. Add it from the start. |
| "PATCH is complicated, let's just use PUT" | PUT requires the full object every time. PATCH is what clients actually want. |
| "We'll version the API when we need to" | By then consumers exist and every option is a breaking change. Ship `/v1` from the first commit. |
| "This change needs a new version" | Only if it breaks someone. Additive, optional changes stay in the current version. |
| "Let's keep v1, v2, and v3 alive" | Every live version is a surface you must patch, test, and secure. Two is the working ceiling. |
| "Nobody uses that undocumented behavior" | Hyrum's Law: if it's observable, somebody depends on it. Treat every public behavior as a commitment. |
| "Internal APIs don't need contracts" | Internal consumers are still consumers. Contracts prevent coupling and enable parallel work. |
| "The backend is Python, so snake_case is natural" | The wire format is its own interface. camelCase everywhere, regardless of server language. |
| "GraphQL means clients fetch only what they need, so it's fast" | Not without DataLoaders and complexity limits. Nested queries are N+1 generators by default. |
| "Rate limiting is an ops concern, not a design concern" | Limits shape client retry behavior and belong in the contract. Design them with the endpoint. |

## Red Flags

- Endpoints that return different shapes depending on conditions
- Inconsistent error formats across endpoints
- Validation scattered throughout internal code instead of at boundaries
- Breaking changes to existing fields (type changes, removals)
- List endpoints without pagination
- Verbs in REST URLs (`/api/createTask`, `/api/getUsers`)
- Unversioned endpoints with live external consumers
- snake_case leaking into query params or response bodies
- URL nesting more than two levels deep
- GraphQL relationship fields resolved without a DataLoader
- Public GraphQL endpoint with no depth or complexity limit
- Third-party API responses used without validation or sanitization
- Response shape that is a 1:1 mirror of a database table

## Verification

After designing an API:

- [ ] Every endpoint has typed input and output schemas
- [ ] Error responses follow a single consistent format
- [ ] Validation happens at system boundaries only
- [ ] List endpoints support pagination
- [ ] New fields are additive and optional (backward compatible)
- [ ] A versioning strategy is in place and the version appears in every route
- [ ] Naming follows consistent conventions across all endpoints, camelCase on the wire
- [ ] Rate limits are defined and surfaced via headers
- [ ] GraphQL: every relationship field goes through a DataLoader; depth and complexity are bounded
- [ ] API documentation or types are committed alongside the implementation

For a fuller pre-ship pass, work through `assets/api-design-checklist.md`.
