FROM debian:bookworm-slim

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# ── System dependencies ─────────────────────────────────────────────────────
# Bevy requires these for compilation (even if not rendering in container):
#   - libasound2-dev, libudev-dev: audio and input backends
#   - libwayland-dev, libxkbcommon-dev: Wayland support
#   - libvulkan-dev: GPU/rendering headers (link-time only)
#   - pkg-config: finds system libraries for cargo build scripts
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    pkg-config \
    curl \
    ca-certificates \
    git \
    sudo \
    # Bevy compile-time dependencies
    libasound2-dev \
    libudev-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libvulkan-dev \
    # Useful extras
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -ms /bin/bash -G sudo dev \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev

# Rust toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain stable --profile default \
    && rustup component add \
    clippy \
    rustfmt \
    rust-analyzer \
    rust-src \
    && chmod -R a+rw /usr/local/rustup /usr/local/cargo

# Typst (for wiki)
RUN curl -fsSL "https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/typst

USER dev
WORKDIR /workspace
