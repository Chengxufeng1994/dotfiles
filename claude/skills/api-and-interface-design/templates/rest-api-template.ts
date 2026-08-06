/**
 * Production-shaped REST API template — Express + Zod.
 *
 * Demonstrates: URL versioning, camelCase wire format, boundary validation,
 * RFC 7807 errors through a single exit, pagination, PATCH semantics, and
 * rate limiting.
 *
 * Data access is stubbed. Replace the `db` calls with a real repository.
 */

import express, {
  type NextFunction,
  type Request,
  type Response,
} from 'express';
import { randomUUID } from 'node:crypto';
import cors from 'cors';
import helmet from 'helmet';
import { z } from 'zod';

declare module 'express-serve-static-core' {
  interface Request {
    requestId: string;
  }
}

const app = express();
app.use(express.json({ limit: '1mb' }));
app.use(helmet());

// Request ID on every response, echoed into each error's `instance`. Without
// it, "it failed around 3pm" is an unactionable bug report.
app.use((req: Request, res: Response, next: NextFunction) => {
  // An inbound ID is untrusted input that ends up in headers and log lines.
  // Accept it only if it is already a safe token; otherwise mint our own.
  const inbound = req.get('X-Request-ID') ?? '';
  req.requestId = /^[A-Za-z0-9-]{1,64}$/.test(inbound) ? inbound : randomUUID();
  res.setHeader('X-Request-ID', req.requestId);
  next();
});

// CORS: enumerate origins. '*' with credentials is rejected by browsers and
// defeats the point of CORS anyway.
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') ?? ['http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key'],
    maxAge: 86_400,
  }),
);

// ---------------------------------------------------------------------------
// Errors — RFC 7807 Problem Details, one shape for every failure
// ---------------------------------------------------------------------------

// Namespace for every `type` URI. These URIs are as public as endpoint paths:
// clients branch on them, so they can be added to but never repurposed.
const ERRORS = 'https://api.example.com/errors';

interface FieldError {
  field?: string;
  code: string;
  message: string;
  valueProvided?: unknown; // never set this for passwords, tokens, or card numbers
}

class APIError extends Error {
  constructor(
    readonly status: number,
    readonly slug: string, // e.g. 'resource-not-found' → `${ERRORS}/resource-not-found`
    readonly title: string, // fixed per slug; `detail` is what varies per occurrence
    detail: string,
    readonly errors?: FieldError[],
  ) {
    super(detail);
  }
}

const notFound = (resource: string, id: string) =>
  new APIError(
    404,
    'resource-not-found',
    'Resource Not Found',
    `${resource} with ID ${id} does not exist.`,
  );

// ---------------------------------------------------------------------------
// Schemas — the same definitions validate requests and describe the contract
// ---------------------------------------------------------------------------

const UserStatus = z.enum(['ACTIVE', 'INACTIVE', 'SUSPENDED']);

const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  status: UserStatus,
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});
type User = z.infer<typeof UserSchema>;

// Input and output are separate types: input has `password`, output never does.
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  password: z.string().min(8),
  status: UserStatus.default('ACTIVE'),
});

// Every field optional — PATCH updates only what was sent. `.strict()` rejects
// unknown keys so a typo silently becomes a 422 instead of a no-op.
const UpdateUserSchema = z
  .object({
    email: z.string().email(),
    name: z.string().min(1).max(100),
    status: UserStatus,
  })
  .partial()
  .strict();

const ListQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
  status: UserStatus.optional(),
  search: z.string().optional(),
  sortBy: z.enum(['createdAt', 'updatedAt', 'name']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

interface Paginated<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
}

// ---------------------------------------------------------------------------
// Validation middleware — validate at the boundary, trust types after it
// ---------------------------------------------------------------------------

type Source = 'body' | 'query' | 'params';

const validate =
  <T extends z.ZodTypeAny>(schema: T, source: Source = 'body') =>
  (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      return next(
        new APIError(
          422,
          'validation-error',
          'Validation Error',
          `${result.error.issues.length} field(s) failed validation.`,
          // Report every failure at once — one field per round-trip makes the
          // client walk a form back and forth.
          result.error.issues.map((issue) => ({
            field: issue.path.join('.'),
            code: issue.code.toUpperCase(),
            message: issue.message,
          })),
        ),
      );
    }
    // Overwrite with the parsed value so downstream handlers get coerced types
    // (e.g. `page` as a number) rather than raw strings.
    Object.defineProperty(req, source, { value: result.data, writable: true });
    next();
  };

// ---------------------------------------------------------------------------
// Rate limiting — headers on every response, not just when limited
// ---------------------------------------------------------------------------

function rateLimit({ limit, windowMs }: { limit: number; windowMs: number }) {
  // In-memory: each instance enforces its own limit. Use Redis when running
  // more than one replica.
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
      return next(
        new APIError(
          429,
          'rate-limited',
          'Rate Limited',
          `Rate limit of ${limit} requests per ${windowMs / 1000}s exceeded.`,
        ),
      );
    }

    recent.push(now);
    hits.set(key, recent);
    next();
  };
}

// ---------------------------------------------------------------------------
// Routes — versioned from the first commit
// ---------------------------------------------------------------------------

const v1 = express.Router();
v1.use(rateLimit({ limit: 100, windowMs: 60_000 }));

// Wrap async handlers so a rejected promise reaches the error middleware
// instead of hanging the request.
const handle =
  (fn: (req: Request, res: Response) => Promise<unknown>) =>
  (req: Request, res: Response, next: NextFunction) =>
    fn(req, res).catch(next);

v1.get(
  '/users',
  validate(ListQuerySchema, 'query'),
  handle(async (req, res) => {
    const { page, pageSize, status, search, sortBy, sortOrder } =
      req.query as unknown as z.infer<typeof ListQuerySchema>;

    const { rows, totalItems } = await db.users.list({
      offset: (page - 1) * pageSize,
      limit: pageSize,
      status,
      search,
      sortBy,
      sortOrder,
    });

    const body: Paginated<User> = {
      data: rows,
      pagination: {
        page,
        pageSize,
        totalItems,
        totalPages: Math.ceil(totalItems / pageSize),
      },
    };
    res.json(body);
  }),
);

v1.post(
  '/users',
  validate(CreateUserSchema),
  handle(async (req, res) => {
    const input = req.body as z.infer<typeof CreateUserSchema>;

    if (await db.users.findByEmail(input.email)) {
      throw new APIError(
        409,
        'resource-already-exists',
        'Resource Already Exists',
        `A user with email '${input.email}' already exists.`,
        [{ field: 'email', code: 'DUPLICATE', message: 'Already in use.' }],
      );
    }

    const { password, ...rest } = input;
    const user = await db.users.create({
      ...rest,
      passwordHash: await hashPassword(password),
    });

    res.status(201).location(`/api/v1/users/${user.id}`).json(user);
  }),
);

v1.get(
  '/users/:userId',
  handle(async (req, res) => {
    const user = await db.users.findById(req.params.userId);
    if (!user) throw notFound('User', req.params.userId);
    res.json(user);
  }),
);

v1.patch(
  '/users/:userId',
  validate(UpdateUserSchema),
  handle(async (req, res) => {
    const patch = req.body as z.infer<typeof UpdateUserSchema>;
    if (Object.keys(patch).length === 0) {
      throw new APIError(
        422,
        'validation-error',
        'Validation Error',
        'A PATCH must contain at least one field to update.',
      );
    }

    const updated = await db.users.update(req.params.userId, patch);
    if (!updated) throw notFound('User', req.params.userId);
    res.json(updated);
  }),
);

v1.delete(
  '/users/:userId',
  handle(async (req, res) => {
    // Idempotent: deleting an already-deleted user is a success, not a 404.
    await db.users.delete(req.params.userId);
    res.status(204).end();
  }),
);

app.use('/api/v1', v1);

// Liveness: no dependencies, so a database blip can't trigger a restart loop.
app.get('/health', (_req, res) => {
  res.json({ status: 'healthy', version: process.env.APP_VERSION });
});

// Readiness: checks real dependencies, returns 503 when it can't serve.
app.get('/health/ready', async (_req, res) => {
  const checks = { database: await db.ping(), cache: await cache.ping() };
  const healthy = Object.values(checks).every(Boolean);
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
  });
});

// ---------------------------------------------------------------------------
// Error handler — the single exit. Must be registered last.
//
// Consistency that relies on discipline at each `res.status(...).json(...)`
// call site drifts within a week. One handler makes it structural.
// ---------------------------------------------------------------------------

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

  // Log the real error under the same ID the client sees; never send internals.
  if (e.status >= 500) {
    console.error({ err, requestId: req.requestId, path: req.path });
  }

  res
    .status(e.status)
    .type('application/problem+json')
    .json({
      type: `${ERRORS}/${e.slug}`,
      title: e.title,
      status: e.status,
      detail: e.message,
      instance: `/requests/${req.requestId}`,
      ...(e.errors && { errors: e.errors }),
    });
});

app.listen(Number(process.env.PORT ?? 8000));
