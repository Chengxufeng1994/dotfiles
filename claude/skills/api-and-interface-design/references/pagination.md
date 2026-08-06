# Pagination Patterns

## Why Paginate?

Large collections can't be returned all at once due to:
- Performance (slow queries, large payloads)
- Memory constraints (server and client)
- Network timeouts
- Poor user experience

Always paginate collection endpoints.

## Pagination Strategies

### 1. Offset-Based Pagination

Most common and intuitive. Uses `offset` (skip) and `limit` (page size).

**Request:**
```http
GET /users?offset=20&limit=10
```

**Response:**
```json
{
  "data": [
    {"id": 21, "name": "User 21"},
    {"id": 22, "name": "User 22"}
  ],
  "pagination": {
    "offset": 20,
    "limit": 10,
    "total": 150,
    "hasMore": true
  },
  "links": {
    "first": "/users?offset=0&limit=10",
    "prev": "/users?offset=10&limit=10",
    "next": "/users?offset=30&limit=10",
    "last": "/users?offset=140&limit=10"
  }
}
```

**Advantages:**
- Simple to implement
- Easy to understand
- Random access (jump to any page)
- Shows total count

**Disadvantages:**
- Performance degrades with large offsets (database scans many rows)
- Inconsistent results if data changes during pagination
- Inefficient for real-time data
- Database must count total rows (expensive)

**Use when:**
- Small to medium datasets
- Data doesn't change frequently
- Need random page access
- Need total count

### 2. Page-Based Pagination

Simplified offset pagination using page numbers.

**Request:**
```http
GET /users?page=3&pageSize=10
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "page": 3,
    "pageSize": 10,
    "totalPages": 15,
    "totalCount": 150
  },
  "links": {
    "first": "/users?page=1&pageSize=10",
    "prev": "/users?page=2&pageSize=10",
    "next": "/users?page=4&pageSize=10",
    "last": "/users?page=15&pageSize=10"
  }
}
```

**Calculation:**
- `offset = (page - 1) * pageSize`
- `totalPages = ceil(totalCount / pageSize)`

**Same pros/cons as offset-based, but:**
- More intuitive for users (page 1, page 2)
- Common in web applications

### 3. Cursor-Based Pagination

Uses an opaque cursor (pointer) to the next set of results.

**Request:**
```http
GET /users?limit=10
GET /users?cursor=eyJpZCI6MTIzfQ&limit=10
```

**Response:**
```json
{
  "data": [
    {"id": 21, "name": "User 21"},
    {"id": 22, "name": "User 22"}
  ],
  "pagination": {
    "nextCursor": "eyJpZCI6MzB9",
    "prevCursor": "eyJpZCI6MjB9",
    "hasMore": true
  },
  "links": {
    "next": "/users?cursor=eyJpZCI6MzB9&limit=10",
    "prev": "/users?cursor=eyJpZCI6MjB9&limit=10"
  }
}
```

**Cursor structure (base64 encoded):**
```json
{"id": 30, "sort": "createdAt"}
```

**Implementation:**
```sql
-- Database columns stay snake_case; the mapping to camelCase happens at the boundary.
-- First page
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;

-- Next page (cursor points to last item)
SELECT * FROM users
WHERE created_at < '2024-01-15T10:30:00Z'
ORDER BY created_at DESC
LIMIT 10;
```

Encode the cursor so clients treat it as opaque, and fetch one extra row so `hasMore` costs nothing:

```typescript
const encodeCursor = (id: string): string =>
  Buffer.from(JSON.stringify({ id })).toString('base64url');

const decodeCursor = (cursor: string): { id: string } =>
  JSON.parse(Buffer.from(cursor, 'base64url').toString());

async function listUsers(limit: number, cursor?: string) {
  const after = cursor ? decodeCursor(cursor).id : undefined;

  // Fetch one extra row to determine hasMore without a second query
  const rows = await db.users.findMany({
    take: limit + 1,
    ...(after && { cursor: { id: after }, skip: 1 }),
    orderBy: { id: 'asc' },
  });

  const hasMore = rows.length > limit;
  const data = hasMore ? rows.slice(0, limit) : rows;

  return {
    data,
    pagination: {
      nextCursor: hasMore ? encodeCursor(data[data.length - 1].id) : null,
      hasMore,
    },
  };
}
```

An opaque cursor is a contract decision, not just an encoding: once clients can read the fields inside it, Hyrum's Law says some of them will construct their own, and you can never change the cursor's internals again.

**Advantages:**
- Consistent results (no skipped/duplicate items)
- Efficient for large datasets
- Works well with real-time data
- No expensive COUNT query
- Better database performance

**Disadvantages:**
- No random access (can't jump to page 10)
- No total count
- More complex to implement
- Cursor is opaque (users can't modify it)

**Use when:**
- Large datasets
- Data changes frequently
- Infinite scroll UI
- Real-time feeds
- Performance is critical

### 4. Keyset Pagination

Similar to cursor but uses actual field values instead of opaque cursor.

**Request:**
```http
GET /users?afterId=20&limit=10
GET /users?afterCreatedAt=2024-01-15T10:30:00Z&limit=10
```

**Response:**
```json
{
  "data": [
    {"id": 21, "name": "User 21", "createdAt": "2024-01-15T11:00:00Z"},
    {"id": 22, "name": "User 22", "createdAt": "2024-01-15T11:30:00Z"}
  ],
  "pagination": {
    "afterId": 30,
    "limit": 10,
    "hasMore": true
  },
  "links": {
    "next": "/users?afterId=30&limit=10"
  }
}
```

**Implementation:**
```sql
SELECT * FROM users
WHERE id > 20
ORDER BY id ASC
LIMIT 10;
```

**Advantages:**
- Very efficient (uses index)
- Transparent cursor (human readable)
- Consistent results
- Simple implementation

**Disadvantages:**
- Requires indexed column
- No random access
- Sorting limited to cursor field
- Complex for multi-field sorting

**Use when:**
- Simple ordering (by ID, timestamp)
- Need efficient pagination
- Want transparent cursor
- Have proper indexes

### 5. Seek Pagination (Time-Based)

Specialized keyset pagination for time-series data.

**Request:**
```http
GET /events?since=2024-01-15T10:00:00Z&until=2024-01-15T11:00:00Z&limit=100
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "since": "2024-01-15T10:00:00Z",
    "until": "2024-01-15T11:00:00Z",
    "limit": 100,
    "hasMore": true
  },
  "links": {
    "next": "/events?since=2024-01-15T11:00:00Z&until=2024-01-15T12:00:00Z&limit=100"
  }
}
```

**Use for:**
- Time-series data
- Logs and events
- Activity streams
- Analytics data

## Default Limits

Always set reasonable defaults and maximum limits:

```json
{
  "defaultLimit": 20,
  "maxLimit": 100,
  "minLimit": 1
}
```

**Validation:**
```http
GET /users?limit=1000

Response: 422 Unprocessable Entity
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "1 field failed validation.",
  "instance": "/requests/req-abc123",
  "errors": [
    {
      "field": "limit",
      "code": "OUT_OF_RANGE",
      "message": "Limit must be between 1 and 100. Default is 20.",
      "constraints": { "min": 1, "max": 100 }
    }
  ]
}
```

Reject an over-limit request rather than silently clamping it to 100 — a client that asked for 1000 and got 100 back will page as if it received 1000 and skip nine tenths of your data.

## Response Format

### Standard Pagination Object

```json
{
  "data": [...],
  "pagination": {
    "limit": 10,
    "offset": 20,
    "total": 150,
    "hasMore": true,
    "hasPrevious": true
  }
}
```

### Link Header (RFC 5988)

```http
Link: </users?offset=0&limit=10>; rel="first",
      </users?offset=10&limit=10>; rel="prev",
      </users?offset=30&limit=10>; rel="next",
      </users?offset=140&limit=10>; rel="last"
```

**Used by:** GitHub API

### Embedded Links

```json
{
  "data": [...],
  "_links": {
    "self": { "href": "/users?offset=20&limit=10" },
    "first": { "href": "/users?offset=0&limit=10" },
    "prev": { "href": "/users?offset=10&limit=10" },
    "next": { "href": "/users?offset=30&limit=10" },
    "last": { "href": "/users?offset=140&limit=10" }
  }
}
```

## Sorting with Pagination

Always support sorting when paginating:

```http
GET /users?sortBy=createdAt&sortOrder=desc&limit=10
GET /users?sortBy=lastName,firstName&sortOrder=asc&limit=10   # Multi-field
```

Use an explicit `sortOrder` rather than a magic `-` prefix (`sort=-createdAt`). The prefix has to be URL-encoded in some clients, reads as a typo, and gives you nowhere to put a second direction when sorting on multiple fields.

**For cursor pagination, cursor must include sort fields:**
```json
{
  "cursor": {
    "id": 123,
    "createdAt": "2024-01-15T10:30:00Z",
    "sortFields": ["createdAt", "id"]
  }
}
```

## Filtering with Pagination

Combine filtering with pagination:

```http
GET /users?status=active&role=admin&offset=0&limit=10
```

**Important:** Apply filters before pagination:
1. Filter records
2. Count filtered results
3. Apply pagination
4. Return paginated subset

## Total Count

### Include Total Count

```json
{
  "data": [...],
  "pagination": {
    "total": 1523,
    "limit": 10,
    "offset": 20
  }
}
```

**Pros:**
- Clients know total results
- Can calculate total pages
- Better UX (show "Page 3 of 153")

**Cons:**
- COUNT query is expensive
- Slows down response
- Inaccurate for large/changing datasets

### Omit Total Count

```json
{
  "data": [...],
  "pagination": {
    "hasMore": true,
    "limit": 10
  }
}
```

**Use when:**
- Large datasets (COUNT is too slow)
- Real-time data (count changes constantly)
- Cursor pagination
- Infinite scroll UI

### Optional Total Count

Let client request total count:

```http
GET /users?limit=10&includeTotal=true
```

## Edge Cases

### Empty Results

```json
{
  "data": [],
  "pagination": {
    "offset": 0,
    "limit": 10,
    "total": 0,
    "hasMore": false
  }
}
```

### Last Page

```json
{
  "data": [{"id": 150, "name": "Last User"}],
  "pagination": {
    "offset": 140,
    "limit": 10,
    "total": 150,
    "hasMore": false
  },
  "links": {
    "first": "/users?offset=0&limit=10",
    "prev": "/users?offset=130&limit=10",
    "next": null
  }
}
```

### Out of Range

```http
GET /users?offset=10000&limit=10

Response: 200 OK (empty results)
{
  "data": [],
  "pagination": {
    "offset": 10000,
    "limit": 10,
    "total": 150,
    "hasMore": false
  }
}
```

An empty page is the better answer: the request was well-formed, and a client walking pages hits this naturally at the end. Reserve 404 for page-numbered APIs where "page 1000 of 15" is genuinely a client bug worth surfacing:

```http
GET /users?page=1000&pageSize=10

Response: 404 Not Found
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/resource-not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Page 1000 does not exist. There are 15 pages.",
  "instance": "/requests/req-abc123"
}
```

Pick one behaviour and apply it to every collection endpoint — a client cannot handle both.

## Best Practices

1. **Always paginate collections** - Never return unbounded lists
2. **Set reasonable defaults** - Default limit of 20-50 items
3. **Enforce maximum limits** - Prevent excessive loads (max 100-1000)
4. **Include hasMore flag** - Tell clients if more results exist
5. **Provide navigation links** - Make it easy to get next/prev pages
6. **Document pagination** - Explain cursor format, limits, defaults
7. **Be consistent** - Use same pagination pattern across all endpoints
8. **Consider performance** - Choose strategy based on data size/type
9. **Support sorting** - Let clients control result order
10. **Handle edge cases** - Empty results, last page, invalid cursors

## Comparison Matrix

| Feature | Offset | Page | Cursor | Keyset |
|---------|--------|------|--------|--------|
| Performance | Poor for large offsets | Poor | Excellent | Excellent |
| Random access | Yes | Yes | No | No |
| Total count | Yes | Yes | No | Optional |
| Consistency | Poor | Poor | Excellent | Excellent |
| Complexity | Simple | Simple | Medium | Medium |
| Real-time data | Poor | Poor | Excellent | Excellent |
| Database load | High | High | Low | Low |
| Use case | Small datasets | Web UIs | Feeds/streams | Large datasets |
