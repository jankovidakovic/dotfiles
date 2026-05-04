FROM ubuntu:22.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl=7.81.0-1ubuntu1.18 \
 && rm -rf /var/lib/apt/lists/*
