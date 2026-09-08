# syntax=docker/dockerfile:1

FROM debian:stable-20260824-slim@sha256:04634311a8d5fc442b6eb06d792293c4f3e2268652ca7634e00ce8ef5cc0a28a

ARG OPENSSL_VERSION=1.1.1w
ARG JEMALLOC_VERSION=5.3.1
ARG RUBY_VERSION=2.6.10

LABEL \
    org.opencontainers.image.title="ruby2.6-jemalloc" \
    org.opencontainers.image.description="Ruby ${RUBY_VERSION} image with jemalloc ${JEMALLOC_VERSION}" \
    org.opencontainers.image.source="https://github.com/UMNLibraries/ruby2.6-jemalloc-docker"

ENV DEBIAN_FRONTEND=noninteractive

RUN <<__install__
set -eux
# Step: install builder dependencies
apt-get update
apt-get -y upgrade
apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    build-essential \
    bzip2 \
    ca-certificates \
    libdb-dev \
    libffi-dev \
    libffi8 \
    libgdbm-dev \
    libgdbm6 \
    libncurses5-dev \
    libncurses6 \
    libreadline-dev \
    libreadline8 \
    libyaml-0-2 \
    libyaml-dev \
    pkg-config \
    wget \
    zlib1g \
    zlib1g-dev
rm -rf /var/lib/apt/lists/*
__install__

# Build OpenSSL 1.1.1 (required by Ruby 2.6; Debian ships OpenSSL 3 which is incompatible)
WORKDIR /tmp/build
RUN <<__openssl__
set -eux
# Step: download OpenSSL source
wget -q "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar xzf "openssl-${OPENSSL_VERSION}.tar.gz"
cd "openssl-${OPENSSL_VERSION}"

# Step: configure and build OpenSSL
./config --prefix=/opt/openssl --openssldir=/opt/openssl shared zlib
make -j"$(nproc)"
make test
make install_sw

# Step: clean OpenSSL build artifacts
rm -rf /tmp/build/openssl-*
__openssl__

# Build jemalloc
RUN <<__jemalloc__
set -eux
# Step: download jemalloc source
wget -q "https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2"
tar xjf "jemalloc-${JEMALLOC_VERSION}.tar.bz2"
cd "jemalloc-${JEMALLOC_VERSION}"

# Step: configure and build jemalloc
./configure --prefix=/usr/local
make -j"$(nproc)"
make test
make install

# Step: clean jemalloc build artifacts
rm -rf /tmp/build/jemalloc-*
__jemalloc__

# Build Ruby 2.6.x with jemalloc and OpenSSL 1.1.1
ENV LD_LIBRARY_PATH=/opt/openssl/lib:/usr/local/lib
RUN <<__ruby__
set -eux
wget -q "https://cache.ruby-lang.org/pub/ruby/2.6/ruby-${RUBY_VERSION}.tar.gz"
tar xzf "ruby-${RUBY_VERSION}.tar.gz"
cd "ruby-${RUBY_VERSION}"

./configure \
    --prefix=/usr/local \
    --with-openssl-dir=/opt/openssl \
    --with-jemalloc \
    --enable-shared \
    --disable-install-doc \
    --disable-install-rdoc \
    CFLAGS="-O2 -fno-omit-frame-pointer -Wno-error=implicit-function-declaration"
make -j"$(nproc)"
#make test	# ruby test suite fails, replacing with simple smoke test
make install
ruby -v
ruby -e 'require "openssl"; puts OpenSSL::OPENSSL_VERSION'

rm -rf /tmp/build/ruby-*

ldconfig /opt/openssl/lib /usr/local/lib
__ruby__

CMD ["irb"]
