# Use Microsoft devcontainers base image (Debian variant).
# This is a common baseline for VS Code Dev Containers.
FROM mcr.microsoft.com/devcontainers/base:debian

# Use bash with pipefail for RUN steps.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Bats and common shell dev tooling.
# - bats: test runner
# - bats-support / bats-assert / bats-file: helper libraries (system-wide under /usr/lib/bats)
# - shellcheck: shell linter
# - shfmt: shell formatter
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    bats \
    bats-support \
    bats-assert \
    bats-file \
    shellcheck \
    shfmt \
    git \
    ca-certificates \
    coreutils \
    findutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
