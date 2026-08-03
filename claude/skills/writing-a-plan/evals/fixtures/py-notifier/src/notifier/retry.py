import asyncio
import random
from dataclasses import dataclass
from typing import Awaitable, Callable, TypeVar

from notifier.message import ChannelError

T = TypeVar("T")


@dataclass(frozen=True)
class RetryPolicy:
    """指數退避 + jitter。所有管道共用，不要各自實作重試。"""

    max_attempts: int = 5
    base_delay_seconds: float = 1.0
    max_delay_seconds: float = 60.0

    def delay_for(self, attempt: int) -> float:
        raw = min(self.base_delay_seconds * (2 ** (attempt - 1)), self.max_delay_seconds)
        return raw * (0.5 + random.random() / 2)


async def with_retry(policy: RetryPolicy, op: Callable[[], Awaitable[T]]) -> T:
    last: Exception | None = None
    for attempt in range(1, policy.max_attempts + 1):
        try:
            return await op()
        except ChannelError as exc:
            last = exc
            if attempt < policy.max_attempts:
                await asyncio.sleep(policy.delay_for(attempt))
    assert last is not None
    raise last
