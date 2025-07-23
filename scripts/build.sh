#!/bin/sh

echo '============= build.sh =============='
: "${BUD_PLATFORM:=openwrt}"
: "${BUD_VERSION:=24.10.2}"
: "${BUD_TARGET:=x86}"
: "${BUD_SUBTARGET:=64}"
: "${BUD_PROFILE:=generic}"
: "${BUD_TAG_NAME:=${BUD_PLATFORM}-${BUD_VERSION}-${BUD_TARGET}-${BUD_SUBTARGET}-${BUD_PROFILE}}"

if [ "$BUD_PLATFORM" = "openwrt" ]; then
  BUD_IMG_NAME="${BUD_PLATFORM}/imagebuilder:${BUD_TARGET}-${BUD_SUBTARGET}-${BUD_VERSION}"
else
  BUD_IMG_NAME="${BUD_PLATFORM}/imagebuilder:${BUD_TARGET}-${BUD_SUBTARGET}-openwrt-${BUD_VERSION}"
fi

cat <<EOF > ./files/etc/config/.env
BUD_PLATFORM=${BUD_PLATFORM}
BUD_VERSION=${BUD_VERSION}
BUD_TARGET=${BUD_TARGET}
BUD_SUBTARGET=${BUD_SUBTARGET}
BUD_PROFILE=${BUD_PROFILE}
BUD_TAG_NAME=${BUD_TAG_NAME}
BUD_IMG_NAME=${BUD_IMG_NAME}
EOF

echo '============= build.sh .env =============='
cat ./files/etc/config/.env

echo '============= build.sh .cnf =============='
cat ./files/etc/config/.cnf

echo '============= build.sh docker =============='
# https://hub.docker.com/r/openwrt/imagebuilder
# https://hub.docker.com/r/immortalwrt/imagebuilder
docker pull ${BUD_IMG_NAME}
WorkingDir=$(docker image inspect ${BUD_IMG_NAME} --format '{{.Config.WorkingDir}}')
: "${WorkingDir:=/}"

echo $WorkingDir

mkdir -p ./bin
sudo chown -R 1000:1000 ./
ls -al ./

docker run --rm \
  -u 1000:1000 \
  --env-file ./files/etc/config/.env \
  -v ./bin:${WorkingDir}openwrt/bin \
  -v ./files:${WorkingDir}openwrt/files \
  -v ./scripts:${WorkingDir}openwrt/scripts \
  ${BUD_IMG_NAME} \
  /bin/bash ${WorkingDir}openwrt/scripts/docker.sh
