# syntax=docker/dockerfile:1

# ============================================================
# Stage 1: Builder – compile OpenSSL 1.1.1, jemalloc, Ruby
# ============================================================
FROM debian:latest AS builder

ARG OPENSSL_VERSION=1.1.1w
ARG JEMALLOC_VERSION=5.3.0
ARG RUBY_VERSION=2.6.10

ENV DEBIAN_FRONTEND=noninteractive

RUN <<'EOF'
set -eux
# Step: install builder dependencies
apt-get update
apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    build-essential \
    bzip2 \
    ca-certificates \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libreadline-dev \
    libyaml-dev \
    pkg-config \
    wget \
    zlib1g-dev
rm -rf /var/lib/apt/lists/*
EOF

# Build OpenSSL 1.1.1 (required by Ruby 2.6; Debian ships OpenSSL 3 which is incompatible)
WORKDIR /tmp/build
RUN <<EOF
set -eux
# Step: download OpenSSL source
wget -q "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar xzf "openssl-${OPENSSL_VERSION}.tar.gz"
cd "openssl-${OPENSSL_VERSION}"

# Step: configure and build OpenSSL
./config --prefix=/opt/openssl --openssldir=/opt/openssl shared zlib
make -j"$(nproc)"
make install_sw

# Step: clean OpenSSL build artifacts
rm -rf /tmp/build/openssl-*
EOF

# Build jemalloc
RUN <<EOF
set -eux
# Step: download jemalloc source
wget -q "https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2"
tar xjf "jemalloc-${JEMALLOC_VERSION}.tar.bz2"
cd "jemalloc-${JEMALLOC_VERSION}"

# Step: configure and build jemalloc
./configure --prefix=/usr/local
make -j"$(nproc)"
make install

# Step: clean jemalloc build artifacts
rm -rf /tmp/build/jemalloc-*
EOF

# Build Ruby 2.6.x with jemalloc and OpenSSL 1.1.1
ENV LD_LIBRARY_PATH=/opt/openssl/lib:/usr/local/lib
RUN <<EOF
set -eux
# Step: download Ruby source
wget -q "https://cache.ruby-lang.org/pub/ruby/2.6/ruby-${RUBY_VERSION}.tar.gz"
tar xzf "ruby-${RUBY_VERSION}.tar.gz"
cd "ruby-${RUBY_VERSION}"

# Step: configure and build Ruby
./configure \
    --prefix=/usr/local \
    --with-openssl-dir=/opt/openssl \
    --with-jemalloc \
    --enable-shared \
    --disable-install-doc \
    --disable-install-rdoc \
    CFLAGS="-O2 -fno-omit-frame-pointer -Wno-error=implicit-function-declaration"
make -j"$(nproc)"
make install

# Step: clean Ruby build artifacts
rm -rf /tmp/build/ruby-*
EOF

# ============================================================
# Stage 2: Final – minimal runtime image
# ============================================================
FROM debian:latest

ARG RUBY_VERSION=2.6.10

ENV DEBIAN_FRONTEND=noninteractive \
    RUBY_VERSION=${RUBY_VERSION}

RUN <<'EOF'
set -eux
# Step: install runtime dependencies
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    libffi8 \
    libgdbm6 \
    libncurses6 \
    libreadline8 \
    libyaml-0-2 \
    zlib1g
rm -rf /var/lib/apt/lists/*
EOF

# Copy OpenSSL 1.1.1 libraries from builder
COPY --from=builder /opt/openssl /opt/openssl

# Copy Ruby, gems, and jemalloc from builder
COPY --from=builder /usr/local /usr/local

# Register shared library paths so Ruby can find OpenSSL 1.1.1 and jemalloc
RUN <<'EOF'
set -eux
# Step: register OpenSSL runtime path and refresh linker cache
echo "/opt/openssl/lib" > /etc/ld.so.conf.d/openssl.conf
ldconfig
EOF

CMD ["irb"]
