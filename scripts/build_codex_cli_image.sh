#!/usr/bin/env bash

set -euo pipefail

# Usage: ./build_codex_cli_image.sh <version>
# If no version is provided, default to "latest"
VERSION="${1:-latest}"
IMAGE="harbor.cap.tryg.net/ws-framework/codex/codex-cli:$VERSION"

echo "Building Codex CLI Docker image with version: $VERSION"

cd "codex-rs"
cargo build --target x86_64-unknown-linux-gnu --release --bin codex --locked

docker build -t "$IMAGE" -f- . <<'EOF'
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*
COPY target/x86_64-unknown-linux-gnu/release/codex /codex
ENTRYPOINT ["/codex"]
EOF

docker run --rm "$IMAGE" --version

docker push "$IMAGE"
