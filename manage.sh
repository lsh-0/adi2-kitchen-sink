#!/usr/bin/env bash
#  Project tasks.
#
#    ./manage.sh build   build the release tarball and its checksum in Docker,
#                        into dist/
#
#  The build environment, its packages and the Ada toolchain are pinned in
#  the Dockerfile. For a local build instead, install SDL3, SDL3_ttf,
#  SDL3_image and Alire, then run `alr build`.
set -euo pipefail
cd "$(dirname "$0")"

readonly IMAGE=adi2-demo-build

build() {
  docker build --target build -t "$IMAGE" .
  local container
  container=$(docker create "$IMAGE")
  trap 'docker rm "$container" >/dev/null' RETURN
  mkdir -p dist
  rm -f dist/adi2_demo-*
  docker cp "$container:/out/." dist/
  ls -l dist/
  (cd dist && sha256sum -c ./*.sha256)
}

case "${1:-}" in
  build) build ;;
  *)
    sed -n '2,9s/^#  \{0,1\}//p' "$0"
    exit 1
    ;;
esac
