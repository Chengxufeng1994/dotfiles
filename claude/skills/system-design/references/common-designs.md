# Common System Designs

Most system design prompts are variations on a small set of known shapes. Read this when the problem resembles one of these — use it as a **starting shape to adapt to the stated constraints**, not a template to reproduce verbatim. The scale, consistency, and consistency numbers the user gave in step 1-2 should still change the answer; if they don't change anything, the design is being recalled, not reasoned.

## URL shortener

- Core decision: how to generate the short key. Base62-encode an auto-incrementing ID (simple, sequential — leaks creation order and volume), or hash the long URL and take a prefix (need to handle collisions), or pre-generate a pool of random keys (avoids both, adds a key-store dependency).
- Redirect: 301 (permanent) lets browsers cache it — fewer hits to your service, but you lose click analytics. 302 (temporary) keeps every click hitting your service — full analytics, more load. This is a real trade-off to name, not a default.
- Storage: simple key-value (short key → long URL) is enough; the interesting part of this problem is almost always the key-generation scheme and the read-heavy caching strategy, not the schema.

## Rate limiter

- Placement: at the API gateway/edge, before requests reach application servers — the limiter has to be cheap to check, since it runs on every request.
- Algorithm choice is the core trade-off:
  - *Token bucket*: allows bursts up to the bucket size, refills steadily — simple, widely used.
  - *Sliding window*: smoother enforcement, no burst-then-starve pattern at window boundaries, more state to track.
  - *Fixed window*: cheapest to implement, but allows 2x the limit right at a window boundary.
- Distributed state: if there's more than one gateway instance, the counter needs to live somewhere shared (Redis with atomic increment/expire) or be approximate (each instance enforces limit/N locally) — state which one and why.
- Response: reject with `429` and a `Retry-After` header rather than silently dropping the request.

## News feed

- Core decision: fanout-on-write vs fanout-on-read.
  - *Fanout-on-write (push)*: when a user posts, immediately write it into every follower's feed. Fast reads, but a celebrity with 50M followers turns one post into 50M writes.
  - *Fanout-on-read (pull)*: assemble the feed at read time by querying everyone the user follows. No write amplification, but read latency grows with follow count and it's harder to rank/cache.
  - *Hybrid*: push for normal accounts, pull-and-merge for accounts above a follower threshold. This is the answer in most real systems — name the threshold and why.
- Ranking (if in scope) is a separate concern from delivery — don't conflate "how does the post get to the feed" with "what order do posts appear in."

## Chat / messaging

- Real-time delivery: WebSocket (or long-polling as a fallback) for bidirectional low-latency messages, rather than the client polling an HTTP endpoint.
- Delivery guarantee: at-least-once with client-side dedup (message ID) is the common choice — decide what happens to a message sent while the recipient is offline (queue it, and require an ack on delivery).
- Presence (online/offline/typing): a separate lightweight service with a heartbeat, not baked into the message-delivery path — presence updates are high-frequency and shouldn't compete with message throughput.
- Group chat is a different fanout problem from 1:1 — a message in a 500-person group is closer to the news-feed fanout question than to a simple point-to-point send.

## Search autocomplete

- Data structure: a trie of the top-k frequent queries per prefix, precomputed offline and cached — computing top-k live per keystroke is too slow.
- Freshness: trending/breaking queries need a separate fast path (recent-query counting with a shorter update cycle) layered on top of the precomputed trie, since the offline batch won't reflect the last few minutes.
- The read path (every keystroke) must be very low latency — this pushes toward heavy caching/precomputation and away from anything that queries a live database per keystroke.

## Web crawler

- Frontier: a queue of URLs to visit, seeded and continuously refilled as pages are crawled — BFS is the usual traversal so nearby/important pages are prioritized over deep chains.
- Politeness: respect `robots.txt`, and rate-limit per domain — a naive crawler that hammers one domain gets blocked and can look like a DoS.
- Deduplication: hash page content (not just the URL) to skip near-duplicate pages reachable via different URLs.
- Scale: this is an inherently distributed/parallel problem — the frontier and the dedup index both need to be shared state across crawler workers, which is usually the actual design question being asked.

## Unique ID generator

- UUID: no coordination needed, globally unique, but random — bad as a database primary key for range-scanned or time-ordered tables (poor locality, index fragmentation).
- Snowflake-style (64-bit: timestamp + datacenter/worker ID + sequence): time-sortable, compact, requires assigning worker/datacenter IDs but no per-request coordination.
- Database auto-increment: simplest, but doesn't work once there's more than one writable database node — a purely single-node solution.
- The deciding factor is usually whether IDs need to be sortable by creation time (favors Snowflake) or the system is single-writer already (auto-increment is fine, don't over-engineer).
