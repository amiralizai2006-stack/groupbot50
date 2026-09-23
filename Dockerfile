FROM rust:1.89-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . /app/groupbot

RUN git init /app/grammers \
    && cd /app/grammers \
    && git remote add origin https://github.com/Lonami/grammers.git \
    && git fetch --depth 1 origin 9fef0bae1e59b6138ae7777c783983934a80e129 \
    && git checkout FETCH_HEAD

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
