#!/usr/bin/env bash
set -e

git config --global --add safe.directory /workspace

uv sync --group dev
echo 'source "$UV_PROJECT_ENVIRONMENT/bin/activate"' >> /home/dev/.bashrc
echo 'eval "$(fzf --bash)"' >> /home/dev/.bashrc
git config core.hooksPath .githooks

# --yes also adds a UserPromptSubmit hook to settings.json, which is mounted
# read-only, so that write fails. Only the MCP entry in .claude.json is required.
codegraph install --target=claude --location=global --yes --no-permissions \
    || echo "codegraph install: settings.json is read-only, prompt hook skipped" >&2
grep -q '"codegraph"' "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" \
    || { echo "codegraph MCP server was not registered" >&2; exit 1; }
codegraph init
