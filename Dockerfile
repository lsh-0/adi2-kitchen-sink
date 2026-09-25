# Builds the release tarball in a fixed environment. `./manage.sh build`
# runs it and copies /out/adi2_demo-<version>-linux-x86_64.tar.gz and its
# .sha256 checksum from the image into dist/.
#
# The binary links SDL3, SDL3_ttf and SDL3_image dynamically, so the
# machine that runs it needs SDL3 3.2 or later. Building against Debian's
# 3.2 rather than a newer SDL keeps that floor low. Debian rather than
# Alpine: a musl binary cannot load the glibc SDL that desktop
# distributions ship.

FROM debian:trixie-slim AS toolchain

ARG ALR_VERSION=2.1.1
ARG GNAT_VERSION=16.1.0
ARG GPRBUILD_VERSION=26.0.1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip git python3 pkg-config \
      libsdl3-dev libsdl3-ttf-dev libsdl3-image-dev \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/alr.zip \
      "https://github.com/alire-project/alire/releases/download/v${ALR_VERSION}/alr-${ALR_VERSION}-bin-x86_64-linux.zip" \
 && unzip -j /tmp/alr.zip bin/alr -d /usr/local/bin \
 && rm /tmp/alr.zip \
 && alr -n toolchain --select "gnat_native=${GNAT_VERSION}" "gprbuild=${GPRBUILD_VERSION}"

FROM toolchain AS build

WORKDIR /src

# the manifest alone fetches the pinned adi2, so that layer survives edits
# to the demo's sources
COPY alire.toml adi2_demo.gpr ./
RUN alr -n update

COPY . .
RUN alr -n build --release -- -j0 -largs -s \
 && bin/demo_tests

RUN version=$(sed -n 's/^version = "\(.*\)"/\1/p' alire.toml) \
 && pkg=adi2_demo-${version}-linux-x86_64 \
 && mkdir -p /out/$pkg/bin \
 && cp bin/adi2_demo /out/$pkg/bin/ \
 && cp -r share /out/$pkg/ \
 && cp README.md LICENSE /out/$pkg/ \
 && mkdir -p /out/$pkg/licenses/adi2 \
 && cp alire/cache/pins/adi2_*/LICENSE alire/cache/pins/adi2_*/LICENSES/* \
       /out/$pkg/licenses/adi2/ \
 && tar -C /out -czf /out/$pkg.tar.gz $pkg \
 && rm -r /out/$pkg \
 && (cd /out && sha256sum $pkg.tar.gz > $pkg.tar.gz.sha256)
