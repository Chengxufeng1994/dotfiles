from notifier.message import RenderedMessage, SendResult


class SmsChannel:
    """尚未完成——簡訊供應商合約還沒談定，先佔位。不要依賴這個類別。"""

    name = "sms"

    def validate_target(self, target: str) -> None:
        raise NotImplementedError

    async def send(self, message: RenderedMessage) -> SendResult:
        raise NotImplementedError
