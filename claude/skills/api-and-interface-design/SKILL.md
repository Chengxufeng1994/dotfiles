---
name: api-and-interface-design
description: Designs stable APIs and interfaces that are hard to misuse — REST, GraphQL, OpenAPI, and code-level contracts. Use when creating or reviewing REST or GraphQL endpoints, writing an OpenAPI specification, modelling resources and their relationships, choosing a versioning or pagination strategy, defining type contracts and module boundaries between teams, or setting API design standards.
license: MIT
---

# API and Interface Design

## Overview

Design stable, well-documented interfaces that are hard to misuse. Good interfaces make the right thing easy and the wrong thing hard. This applies to REST APIs, GraphQL schemas, module boundaries, component props, and any surface where one piece of code talks to another.

All examples here are TypeScript, YAML, or SDL. The principles are language-agnostic; translate the syntax, not the shape.

Two rules are settled for every API designed with this skill, so nothing downstream has to re-litigate them:

- **Errors are RFC 7807 Problem Details**, served as `application/problem+json`.
- **The wire format is camelCase**, whatever the backend language is.

## Design Loop

Each step ends on a condition you can check. Do not move on until it holds.

1. **Model the domain** — Identify resources, their relationships, and their lifecycle states.
   *Done when:* every resource and relationship is written down as a table or diagram, before a single path exists.
2. **Define the contract** — Write the interface before the implementation: OpenAPI paths, SDL schema, or TypeScript interfaces.
   *Done when:* every operation has a typed input schema and a typed output schema.
3. **Settle errors and collections** — Decide what each operation can fail with, and how every list is paged.
   *Done when:* every 4xx/5xx the API can emit has a stable `type` URI in the error catalogue, and every collection endpoint names its pagination strategy.
4. **Write the spec** — Produce the OpenAPI 3.1 document (or the SDL).
   *Done when:* `npx @redocly/cli lint openapi.yaml` exits with no errors.
5. **Mock and exercise** — Serve the contract before anyone implements against it.
   *Done when:* `npx @stoplight/prism-cli mock openapi.yaml` serves the spec, and you have exercised one success path and one error path per resource.
6. **Plan evolution** — Decide how this API changes after it has consumers.
   *Done when:* a versioning strategy is chosen and a deprecation policy states a sunset date format, not an intention.

## Reference Map

Start with this file. Drop into a reference only when this file is insufficient.

| File | Contains |
|---|---|
| `references/rest.md` | HTTP method semantics, status codes, filtering, rate limiting, caching, conditional requests, idempotency, bulk operations, content negotiation, HATEOAS/HAL, auth headers |
| `references/graphql.md` | Schema organization, nullability, interfaces/unions, Relay cursor pagination, input/payload mutations, DataLoader, depth and complexity limits, directives, schema evolution |
| `references/openapi.md` | OpenAPI 3.1 structure, components, security schemes, data types, validation keywords, code generation, linting |
| `references/pagination.md` | Offset, page, cursor, keyset, and seek pagination; default limits, total counts, edge cases, comparison matrix |
| `references/versioning.md` | URI/header/query/content-negotiation versioning, version lifecycle, deprecation timelines, migration guides, version discovery |
| `references/error-handling.md` | RFC 7807 catalogue by status class, error code taxonomy, field-level validation, request ID tracking, retry guidance |
| `templates/api-design-checklist.md` | Pre-implementation review checklist (REST + GraphQL) |
| `templates/openapi-starter.yaml` | OpenAPI 3.1 starter with pagination and shared Problem responses |
| `templates/rest-api-template.ts` | Working Express + Zod REST endpoint template |

## Core Principles

### Hyrum's Law

> With a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody, regardless of what you promise in the contract.

Every public behavior — including undocumented quirks, error message text, timing, and ordering — becomes a de facto contract once users depend on it. Design implications:

- **Be intentional about what you expose.** Every observable behavior is a potential commitment.
- **Don't leak implementation details.** If users can observe it, they will depend on it. API structure should not mirror your database schema.
- **Plan for deprecation at design time.** See `references/versioning.md` for how to safely remove things users depend on.
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

### 2. One Error Shape: RFC 7807

Every HTTP error leaves through the same shape, served as `Content-Type: application/problem+json`:

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The 'email' field must be a valid email address.",
  "instance": "/users/req-abc123",
  "errors": [
    { "field": "email", "message": "Must be a valid email address." }
  ]
}
```

- `type` is the machine-readable identity and must be a stable, documented URI — never a generic string, never a bare code that changes meaning between versions. It doubles as the link consumers follow to your error docs.
- `title` is a short, fixed summary of the `type`. `detail` is specific to this occurrence and must be actionable.
- `instance` identifies this occurrence — a request ID URI is the most useful choice.
- `errors[]` is the extension for field-level validation failures. Nothing else gets invented per endpoint.

Status code mapping:

```
400 → Malformed request (unparseable body, bad content type)
401 → Not authenticated
403 → Authenticated but not authorized
404 → Resource not found
409 → Conflict (duplicate, version mismatch)
422 → Well-formed but semantically invalid
429 → Rate limited (include Retry-After)
500 → Server error (never expose internal details)
```

**Route every failure through one handler.** If some endpoints throw, others return null, and others invent their own body, the consumer cannot predict behavior. See `references/error-handling.md` for the catalogue by status class and `templates/rest-api-template.ts` for the single-exit handler.

GraphQL is the one exception: RFC 7807 is HTTP semantics, and a GraphQL response is `200` with a partial result. Return expected errors in the mutation payload as typed `UserError` values instead — using the same slugs as your `type` URIs so one taxonomy covers both surfaces. See `references/graphql.md`.

### 3. Validate at Boundaries

Trust internal code. Validate at system edges where external input enters:

```typescript
// Validate at the API boundary
app.post('/api/v1/tasks', async (req, res) => {
  const result = CreateTaskSchema.safeParse(req.body);
  if (!result.success) {
    return res
      .status(422)
      .type('application/problem+json')
      .json({
        type: 'https://api.example.com/errors/validation-error',
        title: 'Validation Error',
        status: 422,
        detail: 'One or more fields failed validation.',
        instance: req.id,
        errors: result.error.issues.map((i) => ({
          field: i.path.join('.'),
          message: i.message,
        })),
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
- External service response parsing (third-party data — **always treat as untrusted**)
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

Header versioning (`Accept: application/vnd.api+json; version=2`) and query-parameter versioning (`?version=2`) are alternatives with real tradeoffs — see `references/versioning.md` before choosing one.

Rules that keep versioning from multiplying maintenance cost:

- **Bump only for breaking changes.** New optional fields, new endpoints, and new enum values stay in the current version.
- **Cap the number of live versions.** Two is a working ceiling: current and one deprecated. More than that and every fix must be backported N times.
- **Announce deprecation with a date, not a vibe.** Ship the sunset timeline alongside the new version, and signal it in-band with `Deprecation` and `Sunset` headers.
- **GraphQL versions differently.** Evolve the schema in place with `@deprecated` rather than minting `/graphql/v2`.

### 6. Predictable Naming

| Pattern | Convention | Example |
|---------|-----------|---------|
| REST endpoints | Plural nouns, no verbs | `GET /api/v1/tasks`, `POST /api/v1/tasks` |
| Multi-word paths | kebab-case | `/api/v1/order-items` |
| Query params | camelCase | `?sortBy=createdAt&pageSize=20` |
| Response fields | camelCase | `{ createdAt, updatedAt, taskId }` |
| Boolean fields | is/has/can prefix | `isComplete`, `hasAttachments` |
| Enum values | UPPER_SNAKE | `"IN_PROGRESS"`, `"COMPLETED"` |
| Error `type` URIs | kebab-case slug under an errors namespace | `https://api.example.com/errors/rate-limited` |
| GraphQL fields | camelCase | `createdAt`, `postCount` |
| GraphQL types | PascalCase | `User`, `OrderConnection` |

**camelCase everywhere in the wire format** — query params, request bodies, response bodies, and GraphQL fields. Do not let a backend language's naming convention leak into the API surface. A Python or Go service still returns `createdAt`, not `created_at`. Database columns stay snake_case; the mapping happens at the boundary.

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

Paginate every list endpoint. Cursor pagination is the default for large or append-heavy collections:

```typescript
// Request
GET /api/v1/tasks?limit=20&cursor=eyJpZCI6MTIzfQ

// Response
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTQzfQ",
    "hasMore": true
  }
}
```

Offset pagination is fine for bounded, browsable collections where users jump to a page number. Keyset and seek variants, default limits, and total-count tradeoffs are in `references/pagination.md`.

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
  code: ErrorCode!   # same slugs as the REST error `type` URIs
}
```

Full schema patterns, resolver structure, DataLoader implementation, and complexity limiting live in `references/graphql.md`.

## Code-Level Contracts

The same discipline applies below the network boundary — module exports, component props, and service interfaces are public surfaces too.

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
| "Our own error format is simpler than RFC 7807" | It is one more thing every client must learn. 7807 has off-the-shelf parsers and a documented `type` URI. |
| "GraphQL means clients fetch only what they need, so it's fast" | Not without DataLoaders and complexity limits. Nested queries are N+1 generators by default. |
| "Rate limiting is an ops concern, not a design concern" | Limits shape client retry behavior and belong in the contract. Design them with the endpoint. |

## Red Flags

- Endpoints that return different shapes depending on conditions
- Error bodies that are not RFC 7807, or are sent without `application/problem+json`
- An error `type` that is a generic string rather than a stable, documented URI
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

- [ ] Resource model and relationships are documented (diagram or table)
- [ ] Every endpoint has typed input and output schemas
- [ ] Every error the API can emit is catalogued with its `type` URI and status code
- [ ] Error responses are `application/problem+json` and share one shape
- [ ] Validation happens at system boundaries only
- [ ] List endpoints support pagination
- [ ] New fields are additive and optional (backward compatible)
- [ ] A versioning strategy is in place and the version appears in every route
- [ ] Authentication and authorization flows are documented
- [ ] Naming follows the conventions above, camelCase on the wire
- [ ] Rate limits are defined and surfaced via headers
- [ ] GraphQL: every relationship field goes through a DataLoader; depth and complexity are bounded
- [ ] `npx @redocly/cli lint openapi.yaml` passes with no errors
- [ ] The spec is committed alongside the implementation

For a fuller pre-ship pass, work through `templates/api-design-checklist.md`.
