# syntax=docker/dockerfile:1

# ============================================================
# Stage 1: Builder – compile OpenSSL 1.1.1, jemalloc, Ruby
# ============================================================
FROM debian:latest AS builder

ARG OPENSSL_VERSION=1.1.1w
ARG JEMALLOC_VERSION=5.3.1
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

# Assemble a minimal runtime filesystem for the final scratch image.
RUN <<'EOF'
set -eux

mkdir -p /runtime-root

# Copy Ruby, OpenSSL, and CA certificates required at runtime.
mkdir -p /runtime-root/usr /runtime-root/opt /runtime-root/etc/ssl
cp -a /usr/local /runtime-root/usr/local
cp -a /opt/openssl /runtime-root/opt/openssl
cp -a /etc/ssl/certs /runtime-root/etc/ssl/certs

# Copy dynamic libraries required by Ruby + linked shared libraries.
tmp_lib_list="$(mktemp)"
ldd /usr/local/bin/ruby | awk '{if ($1 ~ /^\//) print $1; else if ($3 ~ /^\//) print $3}' >> "$tmp_lib_list"
ldd /usr/local/lib/libruby.so.2.6 | awk '{if ($1 ~ /^\//) print $1; else if ($3 ~ /^\//) print $3}' >> "$tmp_lib_list"
ldd /usr/local/lib/libjemalloc.so.2 | awk '{if ($1 ~ /^\//) print $1; else if ($3 ~ /^\//) print $3}' >> "$tmp_lib_list"
ldd /opt/openssl/lib/libssl.so.1.1 | awk '{if ($1 ~ /^\//) print $1; else if ($3 ~ /^\//) print $3}' >> "$tmp_lib_list"
ldd /opt/openssl/lib/libcrypto.so.1.1 | awk '{if ($1 ~ /^\//) print $1; else if ($3 ~ /^\//) print $3}' >> "$tmp_lib_list"

sort -u "$tmp_lib_list" | while read -r lib; do
    [ -n "$lib" ]
    [ -e "$lib" ]
    resolved="$(readlink -f "$lib")"

    mkdir -p "/runtime-root$(dirname "$resolved")"
    cp -a "$resolved" "/runtime-root$resolved"

    if [ "$lib" != "$resolved" ]; then
        mkdir -p "/runtime-root$(dirname "$lib")"
        ln -sf "$resolved" "/runtime-root$lib"
    fi
done

rm -f "$tmp_lib_list"
EOF

# ============================================================
# Stage 2: Final – minimal runtime image
# ============================================================
FROM scratch

ARG RUBY_VERSION=2.6.10

ENV LD_LIBRARY_PATH=/opt/openssl/lib:/usr/local/lib \
    RUBY_VERSION=${RUBY_VERSION}

# Copy curated runtime filesystem from builder.
COPY --from=builder /runtime-root/ /

CMD ["irb"]
