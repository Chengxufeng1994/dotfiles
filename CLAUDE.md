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
├── ghostty/         # Ghostty terminal config
├── tmux/            # tmux config
├── zsh/             # Zsh config and aliases
├── git/             # Git config and commit template
├── brewfile/        # Homebrew package lists (Brewfile, Caskfile)
└── Makefile         # All setup targets
```

## Claude Config Structure (`claude/`)

The `claude/` directory mirrors `~/.claude/` and contains:

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions loaded for every session |
| `CLAUDE.workflow-orchestration.md` | Workflow/task management patterns |
| `CLAUDE.kingkongshot.md` | "Linus Torvalds" persona for code reviews |
| `rules/*.md` | Topic-specific rules (coding-style, git-workflow, testing, patterns, security, performance, hooks, agents) |
| `agents/*.md` | Custom subagent definitions (code-reviewer, backend-architect, database-architect, etc.) |
| `commands/*.md` | Custom slash commands (e.g. `/code-review`, `/commit-message`, `/golang-code-review`) |
| `skills/` | Custom skills installed locally |
| `plugins/` | Plugin marketplace config and installed plugins |
| `settings.json` | Claude Code settings (enabled plugins, statusline, hooks) |

## Rules Files

Rules in `claude/rules/` are automatically included. When modifying Claude's behavior for this repo, add to the appropriate rule file rather than creating a new one:

- `coding-style.md` — Go formatting, design principles
- `patterns.md` — Functional options, DI, interfaces
- `testing.md` — Go test framework, race detection, coverage
- `git-workflow.md` — Commit format, PR workflow
- `security.md` — Secret management, gosec, context/timeouts
- `performance.md` — Model selection, context window management
- `agents.md` — Available agents and when to use them

## Adding Skills and Commands

- **New skill**: Add directory under `claude/skills/<name>/` with a `SKILL.md`
- **New command**: Add `claude/commands/<name>.md`
- **New agent**: Add `claude/agents/<name>.md`
- **Plugin management**: Edit `claude/settings.json` `enabledPlugins` section

## Plugins

Plugins are managed via `claude/settings.json`. Active marketplaces:
- `superpowers-marketplace` — obra/superpowers-marketplace
- `everything-claude-code` — affaan-m/everything-claude-code
- `obsidian-skills` — kepano/obsidian-skills
