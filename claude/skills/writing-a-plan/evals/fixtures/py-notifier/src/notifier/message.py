from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class RenderedMessage:
    tenant_id: str
    target: str
    subject: str
    body: str
    template_id: str


@dataclass(frozen=True)
class SendResult:
    delivered_at: datetime
    provider_message_id: str


class ChannelError(Exception):
    """管道送出失敗，可重試。"""


class InvalidTarget(Exception):
    """收件目標格式錯誤，不可重試。"""
