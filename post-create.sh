#!/usr/bin/env bash
set -e

git config --global --add safe.directory /workspace

uv sync --group dev
echo 'source "$UV_PROJECT_ENVIRONMENT/bin/activate"' >> /home/dev/.bashrc
echo 'eval "$(fzf --bash)"' >> /home/dev/.bashrc
# pre-commit refuses to install while a local core.hooksPath is set; clear a stale one first
git config --local --unset-all core.hooksPath || true
uv run pre-commit install --hook-type pre-commit --hook-type pre-push
