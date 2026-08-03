from dataclasses import dataclass
from datetime import datetime
from typing import Protocol

from notifier.message import RenderedMessage


@dataclass
class OutboxEntry:
    id: str
    channel: str
    message: RenderedMessage
    attempts: int
    last_error: str | None
    created_at: datetime
    delivered_at: datetime | None


class OutboxRepository(Protocol):
    """待送佇列。dispatcher 先寫 outbox 再送出，確保程序中斷不掉訊息。"""

    async def enqueue(self, channel: str, message: RenderedMessage) -> OutboxEntry: ...
    async def mark_delivered(self, entry_id: str, at: datetime) -> None: ...
    async def mark_failed(self, entry_id: str, error: str) -> None: ...
    async def claim_pending(self, limit: int) -> list[OutboxEntry]: ...
