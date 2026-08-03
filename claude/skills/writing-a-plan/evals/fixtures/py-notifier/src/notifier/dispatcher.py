from datetime import UTC, datetime

from notifier.channels.base import NotificationChannel
from notifier.message import InvalidTarget
from notifier.outbox import OutboxRepository
from notifier.retry import RetryPolicy, with_retry


class Dispatcher:
    """管道註冊表 + 送出流程。新增管道時在此註冊，其餘流程不需改動。"""

    def __init__(self, outbox: OutboxRepository, policy: RetryPolicy) -> None:
        self._channels: dict[str, NotificationChannel] = {}
        self._outbox = outbox
        self._policy = policy

    def register(self, channel: NotificationChannel) -> None:
        self._channels[channel.name] = channel

    async def dispatch(self, channel_name: str, message) -> None:
        channel = self._channels[channel_name]
        entry = await self._outbox.enqueue(channel_name, message)
        try:
            result = await with_retry(self._policy, lambda: channel.send(message))
        except InvalidTarget as exc:
            await self._outbox.mark_failed(entry.id, str(exc))
            return
        except Exception as exc:
            await self._outbox.mark_failed(entry.id, str(exc))
            raise
        await self._outbox.mark_delivered(entry.id, result.delivered_at or datetime.now(UTC))
