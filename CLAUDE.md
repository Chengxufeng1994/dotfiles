# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles repository for macOS. Config files are symlinked into place using `make softlink`. The `claude/` directory in this repo maps directly to `~/.claude/`.

## Setup Commands

```bash
make softlink        # Symlink all configs to their expected locations
make brew-packages   # Install Homebrew formulae from brewfile/Brewfile
make cask-apps       # Install Homebrew cask apps from brewfile/Caskfile
make npm             # Install latest LTS Node via fnm
```

Bootstrap from scratch (in order):
```bash
make install-brew
make install-ohmyzsh
make install-p10k
make packages
make softlink
```

## Architecture

```
dotfiles/
├── claude/          # ~/.claude/ — Claude Code config (see below)
├── gemini/          # Gemini CLI config with antigravity skills
├── nvim/            # ~/.config/nvim/ — LazyVim-based Neovim config
├── vim/             # Legacy ~/.vimrc
├── ghostty/         # Ghostty terminal config
├── tmux/            # tmux config
├── zsh/             # Zsh config and aliases
├── oh-my-posh/      # oh-my-posh prompt theme
├── git/             # Git config and commit template
├── brewfile/        # Homebrew package lists (Brewfile, Caskfile)
├── .mcp.json        # Project MCP servers (memory, fetch, context7, exa, sequential-thinking)
└── Makefile         # All setup targets
```

## Claude Config Structure (`claude/`)

The `claude/` directory mirrors `~/.claude/` and contains:

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions loaded for every session |
| `CLAUDE.workflow-orchestration.md` | Workflow/task management patterns |
| `CLAUDE.kingkongshot.md` | "Linus Torvalds" persona for code reviews |
| `CLAUDE.andrej-karpathy.md` | Karpathy anti-mistake behavioral guidelines |
| `CLAUDE.enhance-andrej-karpathy.md` | Karpathy 12-rule task template |
| `RTK.md` | RTK (Rust Token Killer) proxy reference — imported by `CLAUDE.md` via `@RTK.md` |
| `rules/*.md` | Topic-specific rules (see Rules Files below) |
| `agents/*.md` | Custom subagent definitions (code-reviewer, backend-architect, database-architect, etc.) |
| `commands/*.md` | Custom slash commands (e.g. `/code-review`, `/commit-message`, `/golang-code-review`) |
| `skills/` | Custom skills installed locally |
| `plugins/` | Plugin marketplace config and installed plugins |
| `settings.json` | Claude Code settings (enabled plugins, statusline, hooks) |

## Rules Files

Rules under `claude/rules/` use the `ecc` (everything-claude-code) layering: a shared base extended by per-language overrides. When modifying Claude's behavior, edit the appropriate existing file rather than creating a new one.

- `context7.md` — when to use the Context7 MCP for live library docs
- `ecc/common/*.md` — shared rules: `coding-style`, `patterns`, `testing`, `git-workflow`, `development-workflow`, `code-review`, `security`, `performance`, `hooks`, `agents`
- `ecc/<lang>/*.md` — overrides for `golang`, `python`, `rust`, `typescript`, `web` (each extends its `common/` counterpart)

## Adding Skills and Commands

- **New skill**: Add directory under `claude/skills/<name>/` with a `SKILL.md`
- **New command**: Add `claude/commands/<name>.md`
- **New agent**: Add `claude/agents/<name>.md`
- **Plugin management**: Edit `claude/settings.json` `enabledPlugins` section

## Plugins

Plugins are enabled in `claude/settings.json` (`enabledPlugins`); marketplace sources live under `claude/plugins/marketplaces/`. This set changes often — read the source of truth rather than a static list:

```bash
ls claude/plugins/marketplaces/                 # configured marketplace sources
jq -r '.enabledPlugins | keys[]' claude/settings.json   # currently enabled plugins
```
