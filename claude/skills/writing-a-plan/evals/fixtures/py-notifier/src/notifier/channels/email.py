import re
from datetime import UTC, datetime

import httpx

from notifier.message import ChannelError, InvalidTarget, RenderedMessage, SendResult

_EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class EmailChannel:
    """透過外部 ESP 的 HTTP API 送信。實作 NotificationChannel Protocol。"""

    name = "email"

    def __init__(self, client: httpx.AsyncClient, api_key: str, sender: str) -> None:
        self._client = client
        self._api_key = api_key
        self._sender = sender

    def validate_target(self, target: str) -> None:
        if not _EMAIL.match(target):
            raise InvalidTarget(f"not an email address: {target}")

    async def send(self, message: RenderedMessage) -> SendResult:
        self.validate_target(message.target)
        try:
            resp = await self._client.post(
                "/v1/send",
                headers={"Authorization": f"Bearer {self._api_key}"},
                json={
                    "from": self._sender,
                    "to": message.target,
                    "subject": message.subject,
                    "html": message.body,
                },
            )
            resp.raise_for_status()
        except httpx.HTTPError as exc:
            raise ChannelError(f"esp send failed: {exc}") from exc
        return SendResult(delivered_at=datetime.now(UTC), provider_message_id=resp.json()["id"])
