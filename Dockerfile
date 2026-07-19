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
        micro \
        gnupg \
        unzip \
        pulseaudio-utils \
    && rm -rf /var/lib/apt/lists/*

# Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg \
      | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" \
      > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y --no-install-recommends terraform \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

RUN curl -fsSL https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_amd64.tar.gz \
    | tar -xz -C /usr/local/bin

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN npm install -g @anthropic-ai/claude-code

RUN groupadd --gid 1000 dev && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev

ENV UV_LINK_MODE=copy
ENV PATH="/workspace/.venv/bin:${PATH}"
ENV PRE_COMMIT_HOME="/.jbdevcontainer/pre-commit"
ENV EDITOR=micro

RUN mkdir -p /.jbdevcontainer/pre-commit && chown -R dev:dev /.jbdevcontainer

WORKDIR /workspace
RUN chown dev:dev /workspace

USER dev

RUN mkdir -p /home/dev/.claude

COPY --chown=dev:dev pyproject.toml uv.lock .pre-commit-config.yaml README.md ./
RUN uv sync --group dev --no-install-project
RUN git config --global user.email "build@example.com" && \
    git config --global user.name "Build" && \
    git init && git add -A && git commit -m init && \
    pre-commit run --all-files; rm -rf .git
