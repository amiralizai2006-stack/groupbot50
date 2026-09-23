FROM rust:1.89-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

COPY . /app/groupbot

RUN git init /app/grammers \
    && cd /app/grammers \
    && git remote add origin https://github.com/Lonami/grammers.git \
    && git fetch --depth 1 origin 9fef0bae1e59b6138ae7777c783983934a80e129 \
    && git checkout FETCH_HEAD

RUN cd /app/grammers \
    && git apply /app/groupbot/patches/grammers.patch

ENV CARGO_BUILD_JOBS=1
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16

RUN cd /app/groupbot && cargo build --release -j 1

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    python3 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/groupbot/target/release/groupbot /app/groupbot
COPY --from=builder /app/groupbot/voice_monitor.py /app/voice_monitor.py
COPY --from=builder /app/groupbot/requirements-voice.txt /app/requirements-voice.txt

CMD ["/app/groupbot"]
