# GraphQL Reference

Detailed patterns behind the GraphQL section of `SKILL.md`. Read this when the top tier is insufficient.

GraphQL fields are camelCase, types are PascalCase, enum values are UPPER_SNAKE. Resolver examples are TypeScript.

## Schema Organization

### Modular Schema Structure

Split the schema by domain and stitch with `extend type`. One monolithic `schema.graphql` becomes unmergeable within a few sprints.

```graphql
# user.graphql
type User {
  id: ID!
  email: String!
  name: String!
  posts: [Post!]!
}

extend type Query {
  user(id: ID!): User
  users(first: Int, after: String): UserConnection!
}

extend type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}

# post.graphql
type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
}

extend type Query {
  post(id: ID!): Post
}
```

## Type Design Patterns

### 1. Nullability

```graphql
type User {
  id: ID!          # Always required
  email: String!   # Required
  phone: String    # Optional (nullable)
  posts: [Post!]!  # Non-null array of non-null posts
  tags: [String!]  # Nullable array of non-null strings
}
```

**Start nullable, tighten later.** Nullable → non-null is a backward-compatible change; non-null → nullable is breaking. A non-null field also propagates failure upward: if its resolver errors, GraphQL nulls out the nearest nullable ancestor, which can blank an entire query branch.

### 2. Interfaces for Polymorphism

```graphql
interface Node {
  id: ID!
  createdAt: DateTime!
}

type User implements Node {
  id: ID!
  createdAt: DateTime!
  email: String!
}

type Post implements Node {
  id: ID!
  createdAt: DateTime!
  title: String!
}

type Query {
  node(id: ID!): Node
}
```

### 3. Unions for Heterogeneous Results

```graphql
union SearchResult = User | Post | Comment

type Query {
  search(query: String!): [SearchResult!]!
}

# Query example
{
  search(query: "graphql") {
    ... on User {
      name
      email
    }
    ... on Post {
      title
      content
    }
    ... on Comment {
      text
      author { name }
    }
  }
}
```

Interfaces share fields; unions share nothing. Pick by whether callers need a common field set.

### 4. Input Types

Never reuse an output type as a mutation argument — the schema forbids it, and the two shapes diverge anyway (inputs lack server-generated fields).

```graphql
input CreateUserInput {
  email: String!
  name: String!
  password: String!
  profile: ProfileInput
}

input ProfileInput {
  bio: String
  avatar: String
  website: String
}

input UpdateUserInput {
  id: ID!
  email: String
  name: String
  profile: ProfileInput
}
```

## Pagination Patterns

### Relay Cursor Pagination (recommended)

```graphql
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Query {
  users(first: Int, after: String, last: Int, before: String): UserConnection!
}

# Usage
{
  users(first: 10, after: "cursor123") {
    edges {
      cursor
      node { id name }
    }
    pageInfo { hasNextPage endCursor }
  }
}
```

```typescript
const encodeCursor = (offset: number): string =>
  Buffer.from(`offset:${offset}`).toString('base64url');

const decodeCursor = (cursor: string): number =>
  Number(Buffer.from(cursor, 'base64url').toString().split(':')[1]);

export const usersResolver = async (
  _parent: unknown,
  { first = 20, after, search }: { first?: number; after?: string; search?: string },
): Promise<UserConnection> => {
  const offset = after ? decodeCursor(after) + 1 : 0;

  // Fetch one extra row to compute hasNextPage without a second round-trip
  const rows = await fetchUsers({ limit: first + 1, offset, search });
  const hasNextPage = rows.length > first;
  const nodes = hasNextPage ? rows.slice(0, first) : rows;

  const edges = nodes.map((node, i) => ({ node, cursor: encodeCursor(offset + i) }));

  return {
    edges,
    pageInfo: {
      hasNextPage,
      hasPreviousPage: offset > 0,
      startCursor: edges.at(0)?.cursor ?? null,
      endCursor: edges.at(-1)?.cursor ?? null,
    },
    totalCount: await countUsers({ search }),
  };
};
```

### Offset Pagination (simpler)

```graphql
type UserList {
  items: [User!]!
  totalItems: Int!
  page: Int!
  pageSize: Int!
}

type Query {
  users(page: Int = 1, pageSize: Int = 20): UserList!
}
```

Acceptable for small bounded lists. Breaks down under concurrent inserts and on deep offsets.

## Mutation Design Patterns

### 1. Input/Payload Pattern

Every mutation takes exactly one `input` argument and returns a payload type. This lets you add fields to either side without a breaking signature change.

```graphql
input CreatePostInput {
  title: String!
  content: String!
  tags: [String!]
}

type CreatePostPayload {
  post: Post
  errors: [UserError!]!
}

type UserError {
  field: String
  message: String!
  code: ErrorCode!
}

enum ErrorCode {
  VALIDATION_ERROR
  UNAUTHORIZED
  NOT_FOUND
  CONFLICT
  INTERNAL_ERROR
}

type Mutation {
  createPost(input: CreatePostInput!): CreatePostPayload!
}
```

**Expected failures go in `errors`, not the transport-level `errors` array.** A failed validation is a normal outcome the client must render; a thrown resolver error is an exception the client can only log. Keeping them separate means clients get typed, field-level errors instead of string parsing.

```typescript
export const createUserResolver = async (
  _parent: unknown,
  { input }: { input: CreateUserInput },
  ctx: Context,
): Promise<CreateUserPayload> => {
  const parsed = CreateUserSchema.safeParse(input);
  if (!parsed.success) {
    return {
      user: null,
      errors: parsed.error.issues.map((issue) => ({
        field: issue.path.join('.'),
        message: issue.message,
        code: 'VALIDATION_ERROR' as const,
      })),
    };
  }

  const existing = await ctx.db.users.findByEmail(parsed.data.email);
  if (existing) {
    return {
      user: null,
      errors: [{ field: 'email', message: 'Email already registered', code: 'CONFLICT' }],
    };
  }

  const user = await ctx.db.users.create({
    ...parsed.data,
    password: await hashPassword(parsed.data.password),
  });

  return { user, errors: [] };
};
```

### 2. Optimistic Response Support

```graphql
input UpdateUserInput {
  id: ID!
  name: String
  clientMutationId: String
}

type UpdateUserPayload {
  user: User
  clientMutationId: String
  errors: [UserError!]!
}
```

Echoing `clientMutationId` lets a client correlate the response with the optimistic update it already applied.

### 3. Batch Mutations

```graphql
input BatchCreateUserInput {
  users: [CreateUserInput!]!
}

type BatchCreateUserPayload {
  results: [CreateUserResult!]!
  successCount: Int!
  errorCount: Int!
}

type CreateUserResult {
  index: Int!
  user: User
  errors: [UserError!]!
}

type Mutation {
  batchCreateUsers(input: BatchCreateUserInput!): BatchCreateUserPayload!
}
```

`index` is what makes partial success usable — without it the client cannot map a failure back to the item that caused it.

## Field Design

### Arguments and Filtering

```graphql
type Query {
  posts(
    # Pagination
    first: Int = 20
    after: String

    # Filtering
    status: PostStatus
    authorId: ID
    tag: String

    # Sorting
    orderBy: PostOrderBy = CREATED_AT
    orderDirection: OrderDirection = DESC

    # Searching
    search: String
  ): PostConnection!
}

enum PostStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
}

enum PostOrderBy {
  CREATED_AT
  UPDATED_AT
  TITLE
}

enum OrderDirection {
  ASC
  DESC
}
```

Enums over free-form strings for sort fields: the schema rejects invalid values before a resolver can interpolate them into a query.

### Computed Fields

```graphql
type User {
  firstName: String!
  lastName: String!
  fullName: String!   # Computed in resolver
  posts: [Post!]!
  postCount: Int!     # Computed — must not load all posts to count them
}

type Post {
  likeCount: Int!
  commentCount: Int!
  isLikedByViewer: Boolean!   # Context-dependent
}
```

Counts must resolve with an aggregate query. Resolving `postCount` by loading the posts array is the single most common GraphQL performance bug.

## N+1 Prevention

### DataLoader

Without a loader, a query returning 100 posts issues 100 separate author lookups. DataLoader collapses them into one batched call per tick.

```typescript
import DataLoader from 'dataloader';

// Batch function must return results in the SAME ORDER as the input keys,
// with null for misses — DataLoader maps them back positionally.
const createUserLoader = () =>
  new DataLoader<string, User | null>(async (userIds) => {
    const users = await db.users.findMany({ where: { id: { in: [...userIds] } } });
    const byId = new Map(users.map((u) => [u.id, u]));
    return userIds.map((id) => byId.get(id) ?? null);
  });

// One-to-many: group children by parent, return [] for parents with none
const createPostsByUserLoader = () =>
  new DataLoader<string, Post[]>(async (userIds) => {
    const posts = await db.posts.findMany({ where: { authorId: { in: [...userIds] } } });
    const byUser = new Map<string, Post[]>();
    for (const post of posts) {
      const bucket = byUser.get(post.authorId) ?? [];
      bucket.push(post);
      byUser.set(post.authorId, bucket);
    }
    return userIds.map((id) => byUser.get(id) ?? []);
  });

// Loaders are per-request. Sharing them across requests leaks one user's
// cached data into another user's response.
export const createContext = (req: Request): Context => ({
  req,
  loaders: {
    user: createUserLoader(),
    postsByUser: createPostsByUserLoader(),
  },
});

export const userResolvers = {
  User: {
    posts: (user: User, _args: unknown, ctx: Context) =>
      ctx.loaders.postsByUser.load(user.id),
  },
  Post: {
    author: (post: Post, _args: unknown, ctx: Context) =>
      ctx.loaders.user.load(post.authorId),
  },
};
```

### Query Depth Limiting

A recursive schema (`user → posts → author → posts → …`) lets one request cost unbounded work. Cap depth on any endpoint reachable from outside.

```typescript
import depthLimit from 'graphql-depth-limit';

const server = new ApolloServer({
  schema,
  validationRules: [depthLimit(7)],
});
```

### Query Complexity Analysis

Depth alone does not stop `users(first: 10000) { posts(first: 10000) { … } }`. Score fields by their multipliers and reject expensive queries before execution.

```typescript
import { createComplexityLimitRule } from 'graphql-validation-complexity';

const server = new ApolloServer({
  schema,
  validationRules: [
    createComplexityLimitRule(1000, {
      scalarCost: 1,
      objectCost: 10,
      listFactor: 20,        // list fields multiply their children's cost
      onCost: (cost) => logger.debug({ queryCost: cost }),
    }),
  ],
});
```

Also disable introspection in production and prefer persisted queries for first-party clients.

## Directives

### Built-in

```graphql
type User {
  name: String!
  email: String! @deprecated(reason: "Use emails field instead")
  emails: [String!]!
  privateData: PrivateData
}

query GetUser($isOwner: Boolean!) {
  user(id: "123") {
    name
    privateData @include(if: $isOwner) {
      ssn
    }
  }
}
```

`@include` and `@skip` are client-side shaping only — they are **not** authorization. Enforce access in the resolver.

### Custom Directives

```graphql
directive @auth(requires: Role = USER) on FIELD_DEFINITION

enum Role {
  USER
  ADMIN
  MODERATOR
}

type Mutation {
  deleteUser(id: ID!): Boolean! @auth(requires: ADMIN)
  updateProfile(input: ProfileInput!): User! @auth
}
```

## Error Handling

### Union Error Pattern

Makes every failure mode part of the type system — clients cannot forget to handle one, because the compiler demands a branch.

```graphql
type ValidationError {
  field: String!
  message: String!
}

type NotFoundError {
  message: String!
  resourceType: String!
  resourceId: ID!
}

type AuthorizationError {
  message: String!
}

union UserResult = User | ValidationError | NotFoundError | AuthorizationError

type Query {
  user(id: ID!): UserResult!
}

# Usage
{
  user(id: "123") {
    ... on User { id email }
    ... on NotFoundError { message resourceType }
    ... on AuthorizationError { message }
  }
}
```

Heavier than the payload `errors` list; worth it on high-traffic queries where exhaustive client handling matters. Use the payload pattern for mutations and this for critical reads.

## Schema Evolution

GraphQL evolves in place. It does not need URL versions — deprecate fields and let usage analytics tell you when removal is safe.

### Field Deprecation

```graphql
type User {
  name: String! @deprecated(reason: "Use firstName and lastName")
  firstName: String!
  lastName: String!
}
```

### Evolution Sequence

```graphql
# v1 — initial
type User {
  name: String!
}

# v2 — add optional field (backward compatible)
type User {
  name: String!
  email: String
}

# v3 — deprecate and add replacements; old field still resolves
type User {
  name: String! @deprecated(reason: "Use firstName/lastName")
  firstName: String!
  lastName: String!
  email: String
}
```

Remove a deprecated field only after field-level usage metrics show zero traffic. Without that telemetry, deprecation is a guess.

## Best Practices Summary

1. **Nullable vs non-null**: start nullable, tighten when guaranteed
2. **Input types**: always, for every mutation
3. **Payload pattern**: expected errors belong in the payload, not the transport errors array
4. **Pagination**: cursor-based for connections, offset only for simple bounded lists
5. **Naming**: camelCase fields, PascalCase types, UPPER_SNAKE enum values
6. **Deprecation**: `@deprecated` instead of removal; remove only when usage hits zero
7. **DataLoaders**: on every relationship field, constructed per request
8. **Complexity limits**: depth *and* complexity, plus introspection off in production
9. **Custom scalars**: for domain types (`Email`, `DateTime`, `URL`, `Money`)
10. **Documentation**: describe every field — the schema is the docs
