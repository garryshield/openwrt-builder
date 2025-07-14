#!/bin/sh

echo '=============  =============='
: "${PLATFORM:=openwrt}"
: "${VERSION:=24.10.2}"
: "${TARGET:=x86}"
: "${SUBTARGET:=64}"
: "${PROFILE:=generic}"
: "${TAG_NAME:=${PLATFORM}-${VERSION}-${TARGET}-${SUBTARGET}-${PROFILE}}"

if [ "$PLATFORM" = "openwrt" ]; then
  IMAGE_TAG="${TARGET}-${SUBTARGET}-${VERSION}"
else
  IMAGE_TAG="${TARGET}-${SUBTARGET}-openwrt-${VERSION}"
fi

cat <<EOF > .env
PLATFORM=${PLATFORM}
VERSION=${VERSION}
TARGET=${TARGET}
SUBTARGET=${SUBTARGET}
PROFILE=${PROFILE}
TAG_NAME=${TAG_NAME}
IMAGE_TAG=${IMAGE_TAG}
EOF

docker run --rm \
  --user root \
  --env-file .env \
  -v ./files:/openwrt/files \
  -v ./bin:/openwrt/bin \
  -v ./scripts:/openwrt/scripts \
  ${PLATFORM}/imagebuilder:${IMAGE_TAG} \
  /bin/bash /openwrt/scripts/docker.sh
