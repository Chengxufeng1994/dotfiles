from typing import Protocol, runtime_checkable

from notifier.message import RenderedMessage, SendResult


@runtime_checkable
class NotificationChannel(Protocol):
    """所有通知管道的共同介面。新增管道 = 實作這個 Protocol 並註冊到 dispatcher。"""

    name: str

    async def send(self, message: RenderedMessage) -> SendResult:
        """送出一則已渲染的訊息。失敗時丟出 ChannelError，由 dispatcher 決定是否重試。"""
        ...

    def validate_target(self, target: str) -> None:
        """檢查收件目標格式；不合法時丟出 InvalidTarget。"""
        ...
