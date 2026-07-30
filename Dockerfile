FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        build-essential \
        bubblewrap \
        socat \
        nodejs \
        npm \
        openssh-client \
        locales-all \
        pulseaudio-utils \
    && rm -rf /var/lib/apt/lists/*

RUN ["/bin/bash", "-c", "set -euo pipefail && \
    curl -fsSL https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz \
      | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/fzf"]

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN npm install -g @anthropic-ai/claude-code

RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh \
    | RTK_INSTALL_DIR=/usr/local/bin sh

RUN groupadd --gid 1000 dev && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev

ENV UV_LINK_MODE=copy
ENV PATH="/workspace/.venv/bin:${PATH}"
ENV PRE_COMMIT_HOME="/.jbdevcontainer/pre-commit"

RUN mkdir -p /.jbdevcontainer/pre-commit && chown -R dev:dev /.jbdevcontainer

WORKDIR /workspace
RUN chown dev:dev /workspace

USER dev

RUN mkdir -p /home/dev/.claude
RUN mkdir -p /home/dev/.config/rtk && \
    chown -R dev:dev /home/dev/.config

COPY --chown=dev:dev .devcontainer/config/rtk.toml /home/dev/.config/rtk/config.toml
COPY --chown=dev:dev pyproject.toml uv.lock .pre-commit-config.yaml README.md ./
RUN uv sync --group dev --no-install-project
RUN git config --global user.email "build@example.com" && \
    git config --global user.name "Build" && \
    git init && git add -A && git commit -m init && \
    pre-commit run --all-files; rm -rf .git
