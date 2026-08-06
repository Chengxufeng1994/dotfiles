# REST API Reference

Detailed patterns behind the REST section of `SKILL.md`. Read this when the top tier is insufficient.

All wire-format names are camelCase. Multi-word path segments use kebab-case (`/api/v1/order-items`) — URLs are case-sensitive in some proxies and camelCase paths are a known source of routing bugs. The camelCase rule applies to query parameters, request bodies, and response bodies.

## URL Structure

### Resource Naming

```
# Good — plural nouns
GET /api/v1/users
GET /api/v1/orders
GET /api/v1/order-items

# Bad — verbs or mixed conventions
GET  /api/v1/getUser
GET  /api/v1/user          (inconsistent singular)
POST /api/v1/createOrder
```

### Nested Resources

```
# Shallow nesting (preferred, max two levels)
GET /api/v1/users/{id}/orders
GET /api/v1/orders/{id}

# Deep nesting (avoid)
GET /api/v1/users/{id}/orders/{orderId}/items/{itemId}/reviews

# Better — promote the sub-resource to a top-level collection
GET /api/v1/order-items/{id}/reviews
```

## HTTP Methods and Status Codes

*Safe* means the method never mutates state. *Idempotent* means N identical requests leave the same end state as one. Clients and proxies retry safe and idempotent methods automatically — so putting a mutation behind GET invites duplicate side effects from a retry you never see.

| Method | Safe | Idempotent | Use Case |
|--------|------|------------|----------|
| GET | Yes | Yes | Retrieve resource(s) |
| HEAD | Yes | Yes | Get metadata only |
| OPTIONS | Yes | Yes | Get allowed methods |
| POST | No | No | Create resource, non-idempotent operations |
| PUT | No | Yes | Replace entire resource |
| PATCH | No | No | Partial update |
| DELETE | No | Yes | Remove resource |

### GET — Retrieve Resources

Safe and idempotent. Never mutates state.

```
GET /api/v1/users              → 200 OK (with list)
GET /api/v1/users/{id}         → 200 OK or 404 Not Found
GET /api/v1/users?page=2       → 200 OK (paginated)
```

### POST — Create Resources

Not idempotent. Use an idempotency key when retries are expected.

```
POST /api/v1/users
  Body: { "name": "John", "email": "john@example.com" }
  → 201 Created
  Location: /api/v1/users/123
  Body: { "id": "123", "name": "John", "createdAt": "..." }

POST /api/v1/users (validation error)
  → 422 Unprocessable Entity
  Content-Type: application/problem+json
  Body: { "type": ".../errors/validation-error", "title": "Validation Error",
          "status": 422, "errors": [...] }
```

### PUT — Replace Resources

Idempotent. Requires the complete object; omitted fields are cleared.

```
PUT /api/v1/users/{id}
  Body: { complete user object }
  → 200 OK (updated)
  → 404 Not Found (doesn't exist)
```

### PATCH — Partial Update

```
PATCH /api/v1/users/{id}
  Body: { "name": "Jane" }   (only changed fields)
  → 200 OK
  → 404 Not Found
```

### DELETE — Remove Resources

Idempotent. Deleting an already-deleted resource should not error.

```
DELETE /api/v1/users/{id}
  → 204 No Content (deleted)
  → 404 Not Found
  → 409 Conflict (can't delete due to references)
```

## Filtering, Sorting, and Searching

```
# Filtering
GET /api/v1/users?status=ACTIVE
GET /api/v1/users?role=ADMIN&status=ACTIVE

# Sorting — explicit field and direction beats a magic "-" prefix
GET /api/v1/users?sortBy=createdAt&sortOrder=desc
GET /api/v1/users?sortBy=name,createdAt&sortOrder=asc

# Searching
GET /api/v1/users?search=john

# Field selection (sparse fieldsets)
GET /api/v1/users?fields=id,name,email
```

## Pagination Patterns

Every list endpoint is paginated. Cursor pagination is the default for large or append-heavy collections; offset pagination is fine for bounded collections users browse by page number.

```
GET /api/v1/users?limit=20&cursor=eyJpZCI6MTIzfQ

{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTQzfQ",
    "hasMore": true
  }
}
```

Keyset and seek variants, default and maximum limits, total-count tradeoffs, Link-header pagination, empty/last/out-of-range edge cases, and the cursor encode/decode implementation live in `pagination.md`.

## Versioning Strategies

URL versioning (`/api/v1/users`) is the default: visible in logs, bug reports, and browser history, and trivial to route side by side. Header versioning (`Accept: application/vnd.api+json; version=2`) and query-parameter versioning (`?version=2`) trade that visibility for one canonical URL per resource.

Keep at most two live versions — current plus one deprecated — and signal deprecation in-band so clients notice without reading a changelog:

```
Deprecation: true
Sunset: Sat, 01 Nov 2025 00:00:00 GMT
Link: <https://docs.example.com/migrations/v2>; rel="deprecation"
```

Strategy tradeoffs, the full version lifecycle, deprecation timelines, migration guides, and version discovery endpoints live in `versioning.md`.

## Rate Limiting

### Headers

Always return limit state, not just a 429 when it is too late to adapt.

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 742
X-RateLimit-Reset: 1640000000

Response when limited:
429 Too Many Requests
Retry-After: 3600
```

### Implementation Pattern

```typescript
import type { Request, Response, NextFunction } from 'express';

interface RateLimitOptions {
  limit: number;      // requests allowed per window
  windowMs: number;   // window length in milliseconds
}

// In-memory limiter — replace the Map with Redis for multi-instance deployments,
// otherwise each instance enforces its own independent limit.
function rateLimit({ limit, windowMs }: RateLimitOptions) {
  const hits = new Map<string, number[]>();

  return (req: Request, res: Response, next: NextFunction) => {
    const key = req.ip ?? 'unknown';
    const now = Date.now();
    const recent = (hits.get(key) ?? []).filter((ts) => now - ts < windowMs);

    res.setHeader('X-RateLimit-Limit', limit);
    res.setHeader('X-RateLimit-Remaining', Math.max(0, limit - recent.length - 1));
    res.setHeader('X-RateLimit-Reset', Math.ceil((now + windowMs) / 1000));

    if (recent.length >= limit) {
      res.setHeader('Retry-After', Math.ceil(windowMs / 1000));
      return res
        .status(429)
        .type('application/problem+json')
        .json({
          type: 'https://api.example.com/errors/rate-limited',
          title: 'Rate Limited',
          status: 429,
          detail: `Rate limit of ${limit} requests per ${windowMs / 1000}s exceeded.`,
          instance: `/requests/${req.requestId}`,
        });
    }

    recent.push(now);
    hits.set(key, recent);
    next();
  };
}

app.use('/api/v1', rateLimit({ limit: 100, windowMs: 60_000 }));
```

## Authentication and Authorization

### Bearer Token

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

401 Unauthorized — missing or invalid token
403 Forbidden   — valid token, insufficient permissions
```

The 401/403 distinction matters: 401 tells the client to re-authenticate, 403 tells it not to bother.

### API Keys

```
X-API-Key: your-api-key-here
```

Never accept credentials in the query string — URLs land in access logs, proxy logs, and browser history.

## Error Response Format

Every error is an RFC 7807 Problem Details document served as `application/problem+json`:

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The 'email' field must be a valid email address.",
  "instance": "/requests/req-abc123",
  "errors": [
    { "field": "email", "message": "Must be a valid email address." }
  ]
}
```

`type` is the stable, documented URI that identifies the failure; `errors[]` is the extension for field-level validation. The catalogue by status class, the `type` URI taxonomy, request-ID tracking, retry guidance, and the single-exit Express handler live in `error-handling.md`.
### Status Code Guidelines

- `200 OK` — successful GET, PATCH, PUT
- `201 Created` — successful POST (include a `Location` header)
- `204 No Content` — successful DELETE
- `400 Bad Request` — malformed request (unparseable body, bad content type)
- `401 Unauthorized` — authentication required or failed
- `403 Forbidden` — authenticated but not authorized
- `404 Not Found` — resource doesn't exist
- `409 Conflict` — state conflict (duplicate email, version mismatch)
- `422 Unprocessable Entity` — well-formed but semantically invalid
- `429 Too Many Requests` — rate limited
- `500 Internal Server Error` — server error
- `503 Service Unavailable` — temporary downtime (include `Retry-After`)

## Caching

```
# Client caching
Cache-Control: public, max-age=3600

# No caching
Cache-Control: no-cache, no-store, must-revalidate

# Conditional requests
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
→ 304 Not Modified
```

ETags also enable optimistic concurrency: require `If-Match` on PATCH/PUT so a client cannot overwrite a change it never saw.

```
PUT /api/v1/users/123
If-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"

→ 412 Precondition Failed (the ETag no longer matches)
```

Use `412` when the failure is a failed HTTP precondition header, and `409` when the conflict is in the payload itself (a stale `version` field, a duplicate unique key). Collapsing both into one status leaves the client unable to tell "refetch and retry" from "your data is wrong".

## Content Negotiation

The client states what it can accept; the server states what it actually sent. Always send an explicit `Content-Type` — a client that has to sniff the body will eventually sniff it wrong.

```
GET /api/v1/users/123
Accept: application/json
```

```
Content-Type: application/json; charset=utf-8   # normal responses
Content-Type: application/problem+json          # every error response
Content-Type: application/hal+json              # hypermedia representations
```

Serving errors as `application/json` instead of `application/problem+json` is the most common miss: RFC 7807 parsers key off the media type, so the body is correct but nothing picks it up.

## Bulk Operations

Batch endpoints must report per-item outcomes — a single top-level status cannot express partial success.

```
POST /api/v1/users/batch
{
  "items": [
    { "name": "User1", "email": "user1@example.com" },
    { "name": "User2", "email": "user2@example.com" }
  ]
}

Response: 207 Multi-Status
{
  "results": [
    { "index": 0, "status": "created", "id": "1" },
    {
      "index": 1,
      "status": "failed",
      "problem": {
        "type": "https://api.example.com/errors/duplicate-email",
        "title": "Duplicate Email",
        "status": 409,
        "detail": "Email already registered."
      }
    }
  ],
  "successCount": 1,
  "errorCount": 1
}
```

Per-item failures carry the same Problem Details document a single-item request would have returned, so a client parses one error shape whether it called the batch endpoint or the individual one.

## Idempotency

```
POST /api/v1/orders
Idempotency-Key: unique-key-123

If a duplicate request arrives:
→ 200 OK (return the cached response, do not create a second order)
```

Required for any non-idempotent operation a client might retry — payments, order creation, outbound messages. Store the key with the response for at least as long as clients might retry.

## CORS Configuration

```typescript
import cors from 'cors';

app.use(
  cors({
    origin: ['https://example.com'],  // never '*' when credentials are allowed
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key'],
    maxAge: 86_400,
  }),
);
```

`origin: '*'` together with `credentials: true` is rejected by browsers, and a reflected-origin wildcard defeats the point of CORS. Enumerate origins.

## Documentation with OpenAPI

Generate the spec from the same schemas that validate requests, so docs cannot drift from behavior.

```typescript
import { z } from 'zod';
import { extendZodWithOpenApi, OpenAPIRegistry } from '@asteasolutions/zod-to-openapi';

extendZodWithOpenApi(z);

const UserSchema = z
  .object({
    id: z.string().openapi({ description: 'Server-generated user ID' }),
    email: z.string().email(),
    name: z.string().min(1).max(100),
    status: z.enum(['ACTIVE', 'INACTIVE', 'SUSPENDED']),
    createdAt: z.string().datetime(),
  })
  .openapi('User');

const registry = new OpenAPIRegistry();
registry.registerPath({
  method: 'get',
  path: '/api/v1/users/{userId}',
  summary: 'Get user by ID',
  tags: ['Users'],
  request: { params: z.object({ userId: z.string() }) },
  responses: {
    200: { description: 'User details', content: { 'application/json': { schema: UserSchema } } },
    404: { description: 'User not found' },
  },
});
```

## Health and Monitoring Endpoints

Keep the liveness check dependency-free — if it queries the database, a database blip triggers a pod restart loop.

```typescript
// Liveness — is the process up?
app.get('/health', (_req, res) => {
  res.json({ status: 'healthy', version: process.env.APP_VERSION });
});

// Readiness — can it actually serve traffic?
app.get('/health/ready', async (_req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalApi: await checkExternalApi(),
  };

  const healthy = Object.values(checks).every(Boolean);
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
  });
});
```

## HATEOAS

Rarely worth the cost, but useful when clients should discover available state transitions rather than hardcode them (workflow and approval APIs).

```typescript
interface UserResponse {
  id: string;
  name: string;
  email: string;
  _links: Record<string, { href: string; method?: string }>;
}

const toUserResponse = (user: User, baseUrl: string): UserResponse => ({
  id: user.id,
  name: user.name,
  email: user.email,
  _links: {
    self: { href: `${baseUrl}/api/v1/users/${user.id}` },
    orders: { href: `${baseUrl}/api/v1/users/${user.id}/orders` },
    update: { href: `${baseUrl}/api/v1/users/${user.id}`, method: 'PATCH' },
    delete: { href: `${baseUrl}/api/v1/users/${user.id}`, method: 'DELETE' },
  },
});
```

Only emit links for transitions the current caller is actually authorized to perform — otherwise the links become a lie and clients build retry loops around 403s.

HAL (`application/hal+json`) is the standardized form of the same idea, adding `_embedded` so a response can inline related resources instead of forcing a follow-up request:

```json
{
  "id": "123",
  "name": "John Doe",
  "_links": { "self": { "href": "/api/v1/users/123" } },
  "_embedded": {
    "orders": [
      { "id": "456", "total": 99.99, "_links": { "self": { "href": "/api/v1/orders/456" } } }
    ]
  }
}
```

Embedding is a cache tradeoff, not a free win: the parent representation now changes whenever any embedded child does.
