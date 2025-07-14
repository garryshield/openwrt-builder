#!/bin/sh

echo '=============  =============='
if [ "$PLATFORM" = "openwrt" ]; then
  curl -sSL -o ./packages/luci-app-openclash_0.46.120_all.ipk https://github.com/vernesong/OpenClash/releases/download/v0.46.120/luci-app-openclash_0.46.120_all.ipk
fi

PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-app-openclash dnsmasq-full -dnsmasq"

# make image \
#   PROFILE="${PROFILE}" \
#   BIN_DIR="/openwrt/bin" \
#   FILES="/openwrt/files" \
#   PACKAGES="${PACKAGES}"

cat << EOF > /openwrt/bin/info.md
${PLATFORM}-${TARGET}-${SUBTARGET}-${PROFILE}-${VERSION}
${PACKAGES}
EOF