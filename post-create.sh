#!/usr/bin/env bash
set -e

git config --global --add safe.directory /workspace

uv sync --group dev
echo 'source "$UV_PROJECT_ENVIRONMENT/bin/activate"' >> /home/dev/.bashrc
echo 'eval "$(fzf --bash)"' >> /home/dev/.bashrc
git config core.hooksPath .githooks

codegraph init
