import pytest

from notifier.channels.email import EmailChannel
from notifier.message import InvalidTarget


@pytest.mark.parametrize(
    ("target", "ok"),
    [("a@b.co", True), ("no-at-sign", False), ("", False)],
)
def test_validate_target(target: str, ok: bool) -> None:
    channel = EmailChannel(client=None, api_key="k", sender="s@example.com")  # type: ignore[arg-type]
    if ok:
        channel.validate_target(target)
    else:
        with pytest.raises(InvalidTarget):
            channel.validate_target(target)
