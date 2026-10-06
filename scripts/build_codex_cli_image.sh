#!/usr/bin/env bash

set -euo pipefail

# Usage: ./build_codex_cli_image.sh <version>
# If no version is provided, default to "latest"
VERSION="${1:-latest}"
IMAGE="harbor.cap.tryg.net/ws-framework/codex/codex-cli:v_$VERSION"
PACKAGE_DIR="codex-rs/target/codex-package"

echo "Building Codex CLI Docker image: $IMAGE"

just assemble-codex-package \
    --target x86_64-unknown-linux-gnu \
    --cargo-profile release \
    --package-dir "$PACKAGE_DIR" \
    --force

docker build -t "$IMAGE" -f- "$PACKAGE_DIR" <<'EOF'
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*
COPY . /opt/codex
ENTRYPOINT ["/opt/codex/bin/codex"]
EOF

docker run --rm "$IMAGE" --version

docker push "$IMAGE"
