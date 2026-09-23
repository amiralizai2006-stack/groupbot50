FROM rust:1.88-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN git clone --depth 1 https://codeberg.org/Lonami/grammers.git /app/grammers

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/groupbot /app/groupbot

CMD ["/app/groupbot"]
