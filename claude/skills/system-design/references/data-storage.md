# Data Storage & Scaling

Read this when the database is the bottleneck, or the design decision, in loop steps 3-4. The database is usually the first thing to break — get the strategy explicit before the rest of the design is built on top of it.

## SQL vs NoSQL

Pick based on data shape and access pattern, not familiarity or trend.

| | SQL | NoSQL |
|---|---|---|
| Best for | ACID transactions, joins, well-defined schema, complex queries | Flexible/evolving schema, very high write throughput, horizontal scale by default |
| Consistency | Strong by default | Often eventual (tunable in some, e.g. Cassandra quorum reads/writes) |
| Scaling | Vertical first, horizontal is harder (sharding) | Horizontal is the native mode |
| Examples | Postgres, MySQL | DynamoDB/Cassandra (wide-column), MongoDB (document), Redis (key-value) |

Many real systems use both — e.g. Postgres for the transactional core, a document store for a flexible activity feed, Redis for hot ephemeral state. Naming *why* a particular store fits a particular access pattern is the actual design decision; "we'll use Postgres" without that is a default, not a choice.

## Scaling order

Vertical scaling (bigger machine) first — it's simpler and has no distributed-systems complexity, but has a ceiling and a single point of failure. Move to horizontal only once that ceiling is real:

1. **Vertical scaling** — bigger instance. Simple, but hard ceiling and still a SPOF.
2. **Read replicas (leader-follower replication)** — one writer, many readers, for read-heavy workloads. Reads may lag the leader; state whether the app can tolerate that lag or needs read-your-writes consistency (route that user's own reads to the leader, or use a session-consistency token).
3. **Multi-leader replication** — multiple writable nodes, typically one per region, for multi-region writes. Introduces conflict resolution (last-write-wins, CRDTs, or app-level merge) — name which one.
4. **Sharding** — partition data across nodes when a single node can no longer hold the writes or the dataset. The expensive, hardest-to-reverse step — treat it as the last resort, not the default plan.

## Sharding strategies

| Strategy | How | Trade-off |
|---|---|---|
| Hash-based | `hash(key) % num_shards` | Even distribution; range queries become expensive (scan every shard) |
| Range-based | Partition by key range (e.g. user ID 0-1M, 1M-2M) | Easy range queries; risk of hotspot if activity clusters in one range |
| Directory-based | Lookup service maps key → shard | Flexible rebalancing; the directory itself becomes a dependency and potential bottleneck |

**Shard key choice is the single highest-leverage decision here** — a bad shard key (e.g. sharding a multi-tenant system by `created_date` when one tenant dominates traffic) recreates the hotspot problem inside "solved" sharding. Pick a key that spreads both storage *and* access evenly.

## Denormalization

Trades storage and write complexity for read speed. Worth it when reads dominate writes by a wide margin and the duplicated data changes rarely (e.g. embedding a username alongside a post so the feed read doesn't need a join). Costly when the duplicated field changes often — every write now fans out to every copy, and getting that fan-out wrong produces silent inconsistency.

## The hotspot / celebrity problem

One key (a viral post, a celebrity account) receives disproportionate traffic and overwhelms its single shard while the rest sit idle. Fixes: a dedicated cache in front of just the hot keys, secondary partitioning of the hot key's data across multiple shards, or a read-replica fan-out specific to that key. Detecting this requires monitoring at the key level, not just the shard level — aggregate shard metrics can look healthy while one key inside a shard is saturated.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Sharding before vertical scaling and read replicas are exhausted | Shard only when a single writable node genuinely can't keep up |
| Choosing a shard key without checking its access pattern | Verify the key distributes both storage and read/write traffic, not just row count |
| Denormalizing frequently-changing data | Reserve denormalization for read-heavy, rarely-changing fields |
| Assuming "NoSQL scales, SQL doesn't" as a blanket rule | Justify by the actual query pattern and consistency need, not the label |
