# Estimation & Building Blocks

Read this when sizing a system (loop step 2) or choosing a component for the high-level design (loop step 3).

## Back-of-the-envelope estimation

The goal is order of magnitude, not precision — round aggressively and say so.

**Powers of two:** 2^10 ≈ 1 thousand · 2^20 ≈ 1 million · 2^30 ≈ 1 billion · 2^40 ≈ 1 trillion

**Latency numbers worth memorizing:**

| Operation | Latency |
|---|---|
| Memory read | ~100 ns |
| SSD read | ~100 μs |
| Disk seek | ~10 ms |
| Same-datacenter round trip | ~0.5 ms |
| Cross-continent round trip | ~150 ms |

**Availability (nines):** 99.9% = 8.77 hours downtime/year · 99.99% = 52.6 minutes/year · 99.999% = 5.26 minutes/year. Converting a stated SLA to a downtime budget makes "highly available" concrete.

**Worked formulas:**

- **QPS:** `DAU × actions-per-user-per-day / 86,400`. Peak is typically 2-5x the average — always give both.
- **Storage:** `records-per-day × record-size × retention-period`. Add index and replication overhead (typically another 1-3x) rather than quoting raw data size as the total.
- **Bandwidth:** `QPS × average-payload-size`, split by read and write since they usually differ by an order of magnitude.

**Example:** 100M DAU, 5 actions/day → ~5,800 QPS average, ~20-30K QPS peak. 500M posts/day at 300 bytes each → ~55 TB/year of raw post data before replication.

## Building blocks

Each block trades one cost for another — introduce it once its specific bottleneck actually appears, not preemptively. Adding every block up front just multiplies the number of things that can fail.

**Load balancers**
- L4 (transport layer): routes on IP/port, fast, protocol-agnostic, no content awareness.
- L7 (application layer): routes on URL/header/cookie, enables content-based routing and canary/blue-green splits, costs more CPU per request.

**Caching**
- Layers, roughly in request order: client → CDN → web-server → application cache (Redis/Memcached) → database query cache.
- Strategies:
  - *Cache-aside*: application checks cache, falls back to DB on miss, writes cache after. Most common; app owns invalidation.
  - *Read-through*: cache itself loads from DB on miss — simpler application code, less control.
  - *Write-through*: write goes to cache and DB synchronously — cache always fresh, write latency includes both.
  - *Write-behind*: write goes to cache, DB updated asynchronously — fast writes, risk of data loss if the cache dies before flush.
- Always name the invalidation story (TTL, explicit invalidation on write, or accept staleness) — a cache without one is a bug generator, not an optimization.

**CDN** — serves static/media assets from edge locations near the user; origin then only serves API/dynamic traffic. The main design question is push (upload triggers distribution) vs pull (CDN fetches from origin on first miss, then caches).

**Message queues (Kafka, RabbitMQ, SQS)**
- Decouple producer from consumer, absorb traffic spikes, enable async processing and retry without blocking the caller.
- Kafka: ordered log, replayable, high throughput, consumers track their own offset — good for streaming/fan-out.
- RabbitMQ/SQS: simpler point-to-point or pub-sub delivery, built-in dead-letter handling — good for task queues.
- Delivery guarantees to state explicitly: at-most-once, at-least-once (requires idempotent consumers), or exactly-once (expensive, usually avoided).

**Consistent hashing** — distributes keys across nodes so that adding/removing a node only remaps ~1/n of the keys, instead of a full rehash. Relevant whenever sharding cache nodes or partitioning data across servers that scale in and out.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Adding a cache, CDN, and queue before any bottleneck is identified | Introduce a block when its specific problem appears — read-heavy DB, spiky writes, static assets |
| Choosing L7 LB by default | Use L4 unless content-based routing is actually needed — it's cheaper and simpler |
| Picking Kafka because it's "industry standard" | Justify by the actual need — replay/ordering (Kafka) vs simple task distribution (SQS/RabbitMQ) |
