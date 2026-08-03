from jinja2 import Environment, StrictUndefined

from notifier.message import RenderedMessage

_env = Environment(undefined=StrictUndefined, autoescape=True)


def render(template_id: str, tenant_id: str, target: str, variables: dict[str, object]) -> RenderedMessage:
    """由 template_id 取出樣板並渲染。缺變數會直接報錯，不做靜默補空字串。"""
    subject_tpl, body_tpl = _load(template_id)
    return RenderedMessage(
        tenant_id=tenant_id,
        target=target,
        subject=_env.from_string(subject_tpl).render(**variables),
        body=_env.from_string(body_tpl).render(**variables),
        template_id=template_id,
    )


def _load(template_id: str) -> tuple[str, str]:
    raise NotImplementedError("樣板來源在 DB，實作見 notifier.templates_db")
