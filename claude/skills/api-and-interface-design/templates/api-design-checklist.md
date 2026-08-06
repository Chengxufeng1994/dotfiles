# API Design Checklist

Work through this before implementation, and again before shipping a breaking change.

## Pre-Implementation Review

### Resource Design

- [ ] Resources are nouns, not verbs
- [ ] Plural names for collections
- [ ] Consistent naming across all endpoints
- [ ] Clear resource hierarchy (nesting no deeper than 2 levels)
- [ ] All CRUD operations properly mapped to HTTP methods
- [ ] Response shape is not a 1:1 mirror of a database table

### Naming and Wire Format

- [ ] Query parameters are camelCase (`sortBy`, `pageSize`)
- [ ] Request and response body fields are camelCase (`createdAt`, `taskId`)
- [ ] No snake_case anywhere on the wire, regardless of backend language
- [ ] Multi-word path segments are kebab-case (`/order-items`)
- [ ] Booleans use `is`/`has`/`can` prefixes
- [ ] Enum values are UPPER_SNAKE

### HTTP Methods

- [ ] GET for retrieval (safe, idempotent)
- [ ] POST for creation
- [ ] PUT for full replacement (idempotent)
- [ ] PATCH for partial updates
- [ ] DELETE for removal (idempotent — deleting twice is not an error)

### Status Codes

- [ ] 200 OK for successful GET/PATCH/PUT
- [ ] 201 Created for POST, with a `Location` header
- [ ] 204 No Content for DELETE
- [ ] 400 Bad Request for malformed requests
- [ ] 401 Unauthorized for missing auth
- [ ] 403 Forbidden for insufficient permissions
- [ ] 404 Not Found for missing resources
- [ ] 409 Conflict for state conflicts
- [ ] 422 Unprocessable Entity for validation errors
- [ ] 429 Too Many Requests for rate limiting
- [ ] 500 Internal Server Error for server issues

### Pagination

- [ ] All collection endpoints paginated
- [ ] Default page size defined (e.g. 20)
- [ ] Maximum page size enforced (e.g. 100)
- [ ] Pagination metadata included (`totalItems`, `totalPages`, or `nextCursor`)
- [ ] Cursor-based chosen for large or append-heavy datasets; offset only for bounded ones

### Filtering & Sorting

- [ ] Query parameters for filtering
- [ ] `sortBy` and `sortOrder` supported
- [ ] Search parameter for full-text search
- [ ] Field selection supported (sparse fieldsets)

### Versioning

- [ ] Versioning strategy defined (URL by default; header/query only with a stated reason)
- [ ] Version present in every route from the first commit
- [ ] Additive changes ship in the current version — no gratuitous bumps
- [ ] At most two live versions (current + one deprecated)
- [ ] Deprecation policy documented, with a sunset date
- [ ] `Deprecation` and `Sunset` headers emitted on deprecated routes

### Error Handling

- [ ] Every error is an RFC 7807 Problem Details document — no second "simpler" shape
- [ ] Served as `Content-Type: application/problem+json`
- [ ] Every `type` is a stable, documented URI, registered in one catalogue
- [ ] `title` is fixed per `type`; `detail` is specific and actionable per occurrence
- [ ] Field-level validation failures in the `errors[]` extension, all reported at once
- [ ] Request ID in `instance`, and in the server-side log for the same failure
- [ ] All failures routed through one handler, not per-route response calls
- [ ] 5xx responses never leak stack traces, SQL, internal paths, or config
- [ ] Retryability signalled via `Retry-After` and the `retry` extension

### Validation

- [ ] Schema validation at every route handler
- [ ] Third-party API responses validated before use
- [ ] Environment variables validated at startup
- [ ] No redundant validation between already-typed internal functions

### Authentication & Authorization

- [ ] Authentication method defined (Bearer token, API key)
- [ ] Authorization checks on all endpoints
- [ ] 401 vs 403 used correctly
- [ ] Token expiration handled
- [ ] No credentials in URLs or query strings

### Rate Limiting

- [ ] Rate limits defined per endpoint/user
- [ ] `X-RateLimit-*` headers included on every response, not just 429s
- [ ] 429 status code for exceeded limits
- [ ] `Retry-After` header provided
- [ ] Shared store (Redis) if running more than one instance

### Documentation

- [ ] OpenAPI spec generated from the same schemas that validate requests
- [ ] `npx @redocly/cli lint openapi.yaml` passes with no errors
- [ ] Spec serves a working mock: `npx @stoplight/prism-cli mock openapi.yaml`
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Every error an endpoint can emit is documented, `$ref`-ing a single shared `Problem` schema
- [ ] Authentication flow documented

### Testing

- [ ] Unit tests for business logic
- [ ] Integration tests for endpoints
- [ ] Error scenarios tested
- [ ] Edge cases covered
- [ ] Performance tests for heavy endpoints

### Security

- [ ] Input validation on all fields
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention
- [ ] CORS origins enumerated — never `*` with credentials
- [ ] HTTPS enforced
- [ ] Sensitive data not in URLs
- [ ] No secrets in responses

### Performance

- [ ] Database queries optimized
- [ ] N+1 queries prevented
- [ ] Caching strategy defined
- [ ] Cache headers set appropriately
- [ ] ETags for conditional requests and optimistic concurrency
- [ ] Large responses paginated

### Reliability

- [ ] Idempotency keys accepted on retryable non-idempotent operations
- [ ] Bulk endpoints report per-item outcomes with an `index`
- [ ] Liveness endpoint has no external dependencies
- [ ] Readiness endpoint checks real dependencies and returns 503 when degraded

### Monitoring

- [ ] Logging implemented
- [ ] Error tracking configured
- [ ] Performance metrics collected
- [ ] Health check endpoint available
- [ ] Alerts configured for errors

## GraphQL-Specific Checks

### Schema Design

- [ ] Schema-first — SDL written before resolvers
- [ ] Types properly defined
- [ ] Nullability decided deliberately (start nullable, tighten later)
- [ ] Interfaces/unions used appropriately
- [ ] Custom scalars defined (`Email`, `DateTime`, `URL`, `Money`)
- [ ] Fields camelCase, types PascalCase, enums UPPER_SNAKE

### Queries

- [ ] Query depth limiting enabled
- [ ] Query complexity analysis enabled
- [ ] DataLoaders prevent N+1 on every relationship field
- [ ] Loaders constructed per request, never shared across requests
- [ ] Count fields resolve via aggregate queries, not by loading collections
- [ ] Introspection disabled in production

### Mutations

- [ ] Single `input` argument per mutation
- [ ] Payload types carry a typed `errors` list
- [ ] Expected failures returned in the payload, not thrown
- [ ] Batch results include a per-item `index`
- [ ] Optimistic response support (`clientMutationId`) where clients need it
- [ ] Idempotency considered

### Performance

- [ ] DataLoader for all relationships
- [ ] Query batching enabled
- [ ] Persisted queries considered for first-party clients
- [ ] Response caching implemented

### Evolution

- [ ] `@deprecated` used instead of removal
- [ ] Field-level usage metrics collected before removing anything
- [ ] No URL versioning on the GraphQL endpoint
- [ ] All fields documented with descriptions
