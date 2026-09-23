FROM rust:1.88-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Project goes in /app/groupbot
COPY . /app/groupbot

# Cargo.toml expects grammers at ../grammers
RUN git clone https://github.com/Lonami/grammers.git /app/grammers \
    && cd /app/grammers \
    && git checkout 9fef0bae1e59b6138ae7777c783983934a80e129

RUN cd /app/grammers \
    && git apply /app/groupbot/patches/grammers.patch

RUN cd /app/groupbot \
    && cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/groupbot/target/release/groupbot /app/groupbot

CMD ["/app/groupbot"]
