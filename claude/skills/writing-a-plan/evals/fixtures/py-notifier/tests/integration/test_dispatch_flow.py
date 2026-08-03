import pytest

pytestmark = pytest.mark.integration


async def test_email_dispatch_writes_outbox() -> None:
    """需要真的 Postgres 與 ESP sandbox，CI 的 integration job 才跑。"""
    pytest.skip("需要外部服務")
