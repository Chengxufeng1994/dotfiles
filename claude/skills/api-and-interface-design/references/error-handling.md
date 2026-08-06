# API Error Handling

Every error this API can emit is an RFC 7807 Problem Details document, served as `Content-Type: application/problem+json`. One shape, one media type, no per-endpoint inventions.

## The Shape

```http
HTTP/1.1 404 Not Found
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/resource-not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User with ID 99999 does not exist.",
  "instance": "/requests/req-abc123"
}
```

| Member | Role |
|---|---|
| `type` | URI identifying the error class. **This is the machine-readable identity** — clients branch on it. It must be stable across versions and should resolve to human documentation. |
| `title` | Short summary, fixed per `type`. Do not vary it per occurrence. |
| `status` | The HTTP status code, duplicated in the body so the document survives being logged or forwarded. |
| `detail` | Explanation specific to *this* occurrence. Actionable, and safe to show a developer. |
| `instance` | URI identifying this occurrence — a request ID URI is the most useful choice. |

Anything beyond these is an **extension member**, added at the top level of the document. The two extensions used throughout this API:

- `errors[]` — field-level validation failures.
- `retry` — machine-readable retry guidance.

Do not nest extensions under a `details` bag. Top-level members are what 7807 tooling and JSON-schema validation expect.

## Error Type Catalogue

Register every `type` URI in one place. This is the contract clients build against, so a `type` is as public as an endpoint path — you can add new ones freely, but you cannot repurpose an existing one.

| `type` (relative to `https://api.example.com/errors/`) | Status | `title` |
|---|---|---|
| `malformed-request` | 400 | Malformed Request |
| `validation-error` | 422 | Validation Error |
| `missing-token` | 401 | Missing Token |
| `invalid-token` | 401 | Invalid Token |
| `expired-token` | 401 | Expired Token |
| `revoked-token` | 401 | Revoked Token |
| `insufficient-permissions` | 403 | Insufficient Permissions |
| `resource-not-found` | 404 | Resource Not Found |
| `resource-already-exists` | 409 | Resource Already Exists |
| `concurrent-modification` | 409 | Concurrent Modification |
| `precondition-failed` | 412 | Precondition Failed |
| `rate-limited` | 429 | Rate Limited |
| `internal-error` | 500 | Internal Error |
| `service-unavailable` | 503 | Service Unavailable |

Slugs are kebab-case. GraphQL `UserError.code` values reuse the same slugs (as `RESOURCE_NOT_FOUND`) so one taxonomy covers both surfaces.

## Error Categories

### 1. Malformed Request (400 Bad Request)

The request could not be parsed at all — broken JSON, wrong content type, missing body.

```http
POST /users
Content-Type: application/json

{"name": "Jane",,}

Response: 400 Bad Request
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/malformed-request",
  "title": "Malformed Request",
  "status": 400,
  "detail": "Request body is not valid JSON (unexpected token at position 16).",
  "instance": "/requests/req-abc123"
}
```

### 2. Validation Errors (422 Unprocessable Entity)

The request parsed fine but the values are semantically invalid. Report **every** failing field in one response — returning them one at a time forces the client through N round-trips to fill in a form.

```http
POST /users
Content-Type: application/json

{
  "name": "",
  "email": "invalid-email",
  "age": 15
}

Response: 422 Unprocessable Entity
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "3 fields failed validation.",
  "instance": "/requests/req-abc123",
  "errors": [
    {
      "field": "name",
      "code": "REQUIRED",
      "message": "Name is required."
    },
    {
      "field": "email",
      "code": "INVALID_FORMAT",
      "message": "Email must be a valid email address."
    },
    {
      "field": "age",
      "code": "OUT_OF_RANGE",
      "message": "Age must be at least 18.",
      "constraints": { "min": 18, "max": 120 }
    }
  ]
}
```

### 3. Authentication Errors (401 Unauthorized)

Missing or invalid credentials. Pair the body with a `WWW-Authenticate` header — that header, not the body, is what HTTP clients and libraries act on.

```http
GET /users/123
Authorization: Bearer invalid_token

Response: 401 Unauthorized
Content-Type: application/problem+json
WWW-Authenticate: Bearer realm="api", error="invalid_token"

{
  "type": "https://api.example.com/errors/expired-token",
  "title": "Expired Token",
  "status": 401,
  "detail": "The access token expired at 2024-01-15T10:00:00Z.",
  "instance": "/requests/req-abc123",
  "expiredAt": "2024-01-15T10:00:00Z"
}
```

Distinct types let a client tell "refresh the token and retry" (`expired-token`) from "stop and re-authenticate the user" (`revoked-token`) without string-matching a message.

### 4. Authorization Errors (403 Forbidden)

Authenticated, but not allowed.

```http
DELETE /users/123
Authorization: Bearer valid_token

Response: 403 Forbidden
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/insufficient-permissions",
  "title": "Insufficient Permissions",
  "status": 403,
  "detail": "Deleting a user requires the 'users:delete' permission.",
  "instance": "/requests/req-abc123",
  "requiredPermission": "users:delete"
}
```

Do not echo back the caller's full permission list. It tells an attacker exactly which scope to go after next; the required permission alone is enough for a legitimate client to act on.

### 5. Not Found (404 Not Found)

```http
GET /users/99999

Response: 404 Not Found
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/resource-not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User with ID 99999 does not exist.",
  "instance": "/requests/req-abc123",
  "resourceType": "User",
  "resourceId": "99999"
}
```

Return 404 rather than 403 when merely confirming a resource exists would leak information to a caller who cannot see it.

### 6. Conflict (409 Conflict)

The request collides with current state.

```http
POST /users
Content-Type: application/json

{ "email": "existing@example.com", "name": "John Doe" }

Response: 409 Conflict
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/resource-already-exists",
  "title": "Resource Already Exists",
  "status": 409,
  "detail": "A user with email 'existing@example.com' already exists.",
  "instance": "/requests/req-abc123",
  "conflictingField": "email",
  "existingResource": "/api/v1/users/123"
}
```

A failed `If-Match` precondition header is `412 Precondition Failed`, not 409 — see `rest.md`.

### 7. Rate Limiting (429 Too Many Requests)

```http
GET /users

Response: 429 Too Many Requests
Content-Type: application/problem+json
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705320000

{
  "type": "https://api.example.com/errors/rate-limited",
  "title": "Rate Limited",
  "status": 429,
  "detail": "Rate limit of 100 requests per hour exceeded.",
  "instance": "/requests/req-abc123",
  "limit": 100,
  "window": "1h",
  "resetAt": "2024-01-15T11:00:00Z",
  "retry": { "retryable": true, "retryAfter": 60, "backoff": "exponential" }
}
```

`Retry-After` in the header is mandatory. The body repeats it for humans reading logs; libraries read the header.

### 8. Server Errors (500 Internal Server Error)

```http
GET /users/123

Response: 500 Internal Server Error
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/internal-error",
  "title": "Internal Error",
  "status": 500,
  "detail": "An unexpected error occurred. Quote the instance ID when reporting this.",
  "instance": "/requests/req-abc123"
}
```

The `detail` of a 5xx is deliberately uninformative — everything useful goes to the server log under the same instance ID. Never send:

- Stack traces
- Database driver errors or SQL fragments
- Internal file paths or hostnames
- Configuration values

### 9. Service Unavailable (503 Service Unavailable)

```http
GET /users

Response: 503 Service Unavailable
Content-Type: application/problem+json
Retry-After: 300

{
  "type": "https://api.example.com/errors/service-unavailable",
  "title": "Service Unavailable",
  "status": 503,
  "detail": "Scheduled maintenance until 2024-01-15T12:00:00Z.",
  "instance": "/requests/req-abc123",
  "retry": { "retryable": true, "retryAfter": 300, "backoff": "constant" }
}
```

## Validation Error Details

The `errors[]` extension carries one entry per failure. `field` uses dotted and bracketed paths so a client can map a failure straight onto a nested form control.

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "2 fields failed validation.",
  "instance": "/requests/req-abc123",
  "errors": [
    {
      "field": "creditCard.number",
      "code": "INVALID_FORMAT",
      "message": "Credit card number must be 16 digits.",
      "constraints": { "pattern": "^[0-9]{16}$" }
    },
    {
      "field": "items[0].quantity",
      "code": "OUT_OF_RANGE",
      "message": "Quantity must be at least 1.",
      "valueProvided": 0,
      "constraints": { "min": 1, "max": 1000 }
    }
  ]
}
```

Never echo the submitted value back for secrets — no `valueProvided` on password, token, or card-number fields. It ends up in logs and error-tracking services.

### Cross-Field Validation

When the failure is a relationship between fields rather than one bad value, use `fields[]`:

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The requested date range is invalid.",
  "instance": "/requests/req-abc123",
  "errors": [
    {
      "fields": ["startDate", "endDate"],
      "code": "INVALID_RANGE",
      "message": "End date must be after start date.",
      "valuesProvided": { "startDate": "2024-01-20", "endDate": "2024-01-15" }
    }
  ]
}
```

## Request ID Tracking

Every response carries a request ID; every error puts it in `instance`. Without it, a user report of "it failed around 3pm" is unactionable.

```http
Response Headers:
X-Request-ID: req-abc123

Response Body:
{
  "type": "https://api.example.com/errors/internal-error",
  "title": "Internal Error",
  "status": 500,
  "detail": "An unexpected error occurred. Quote the instance ID when reporting this.",
  "instance": "/requests/req-abc123"
}
```

Log the real cause server-side keyed by the same ID, so support can join a user's screenshot to a stack trace.

## The Single Exit

Every failure leaves through one handler. This is what makes the shape actually consistent — scattered `res.status(...).json(...)` calls drift within a week.

```typescript
const ERRORS = 'https://api.example.com/errors';

interface FieldError {
  field?: string;
  fields?: string[];
  code: string;
  message: string;
  constraints?: Record<string, unknown>;
}

class APIError extends Error {
  constructor(
    readonly status: number,
    readonly slug: string,   // e.g. 'resource-not-found'
    readonly title: string,
    detail: string,
    readonly errors?: FieldError[],
  ) {
    super(detail);
  }
}

export const notFound = (resource: string, id: string) =>
  new APIError(404, 'resource-not-found', 'Resource Not Found', `${resource} with ID ${id} does not exist.`);

// Register last, after every route.
app.use((err: unknown, req: Request, res: Response, _next: NextFunction) => {
  const e =
    err instanceof APIError
      ? err
      : new APIError(
          500,
          'internal-error',
          'Internal Error',
          'An unexpected error occurred. Quote the instance ID when reporting this.',
        );

  // Log the real error server-side; never leak internals to the client.
  if (e.status >= 500) logger.error({ err, requestId: req.id, path: req.path });

  res
    .status(e.status)
    .type('application/problem+json')
    .json({
      type: `${ERRORS}/${e.slug}`,
      title: e.title,
      status: e.status,
      detail: e.message,
      instance: `/requests/${req.id}`,
      ...(e.errors && { errors: e.errors }),
    });
});
```

## Error Documentation

Document every error an endpoint can emit, with the `Problem` schema and named examples. If it is not in the spec, clients will discover it in production.

```yaml
/users/{id}:
  get:
    responses:
      '200':
        description: Success
      '401':
        description: Authentication failed
        content:
          application/problem+json:
            schema:
              $ref: '#/components/schemas/Problem'
            examples:
              missingToken:
                value:
                  type: https://api.example.com/errors/missing-token
                  title: Missing Token
                  status: 401
                  detail: No authentication token was provided.
              expiredToken:
                value:
                  type: https://api.example.com/errors/expired-token
                  title: Expired Token
                  status: 401
                  detail: The access token expired at 2024-01-15T10:00:00Z.
      '404':
        description: User not found
        content:
          application/problem+json:
            schema:
              $ref: '#/components/schemas/Problem'
            examples:
              notFound:
                value:
                  type: https://api.example.com/errors/resource-not-found
                  title: Resource Not Found
                  status: 404
                  detail: User with ID 123 does not exist.
```

## Retry Guidance

Tell the client whether retrying is worth it, rather than letting it guess from the status code alone.

```json
{
  "type": "https://api.example.com/errors/service-unavailable",
  "title": "Service Unavailable",
  "status": 503,
  "detail": "Upstream dependency is unreachable.",
  "instance": "/requests/req-abc123",
  "retry": {
    "retryable": true,
    "retryAfter": 60,
    "maxRetries": 3,
    "backoff": "exponential"
  }
}
```

**Retryable:** 408 Request Timeout, 429 Too Many Requests (honour `Retry-After`), 500 Internal Server Error (only for idempotent operations), 502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout.

**Not retryable:** 400, 401, 403, 404, 409, 422. Retrying these produces the same result and burns the client's rate limit.

Retrying a non-idempotent POST after a 500 or 504 risks a duplicate side effect — the server may have completed the work before failing to respond. Require an `Idempotency-Key` on those endpoints so a retry is safe.

## Multi-Language Support

Translate `detail`, never `type`. The `type` URI is the machine contract; the prose is the presentation layer.

```http
GET /users/invalid
Accept-Language: es

Response: 404 Not Found
Content-Type: application/problem+json
Content-Language: es

{
  "type": "https://api.example.com/errors/resource-not-found",
  "title": "Recurso No Encontrado",
  "status": 404,
  "detail": "El usuario con ID 'invalid' no existe.",
  "instance": "/requests/req-abc123"
}
```

Because `type` is stable across languages, a client that ships its own translations can ignore `detail` entirely and key off the URI.

## Best Practices

1. **Use standard HTTP status codes** — never return 200 with an error in the body.
2. **Serve `application/problem+json`** — 7807 parsers key off the media type.
3. **Keep `type` URIs stable and documented** — they are as public as endpoint paths.
4. **Vary `detail`, fix `title`** — one is per-occurrence, the other is per-type.
5. **Be specific but safe** — actionable for the caller, silent about internals.
6. **Put a request ID in `instance`** — and log the real cause under the same ID.
7. **Report all validation failures at once** — not one field per round-trip.
8. **Document every error per endpoint** — with the `Problem` schema and examples.
9. **Signal retryability** — via `Retry-After` and the `retry` extension.
10. **Route everything through one handler** — consistency that depends on discipline at each call site will not hold.

## Anti-Patterns

- Returning 200 with an error payload
- A per-endpoint error shape, or a second "simpler" shape for internal callers
- `type` values that are bare strings, or that get repurposed between versions
- Generic `detail` text ("An error occurred") that gives the caller nothing to act on
- Stack traces, SQL fragments, or internal paths in a 5xx response
- Errors with no request ID, making a user's bug report untraceable
- Undocumented errors that clients first meet in production
- Echoing submitted secrets back in `valueProvided`
