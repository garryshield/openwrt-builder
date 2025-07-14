#!/bin/sh

echo '=============  =============='

PACKAGES="${PACKAGES:+$PACKAGES }curl"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-openclash"

if [ "$PLATFORM" = "openwrt" ]; then
  curl -sSL -o ./packages/luci-app-openclash_0.46.133_all.ipk https://raw.githubusercontent.com/vernesong/OpenClash/package/master/luci-app-openclash_0.46.133_all.ipk
  PACKAGES="${PACKAGES:+$PACKAGES }luci luci-compat luci-i18n-base-zh"
  PACKAGES="${PACKAGES:+$PACKAGES }dnsmasq-full -dnsmasq"
fi

mkdir -p /openwrt/files/etc/openclash/core
META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
wget -qO- $META_URL | tar xOvz > /openwrt/files/etc/openclash/core/clash_meta
chmod +x /openwrt/files/etc/openclash/core/clash_meta

make image \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files" \
  PROFILE="${PROFILE}" \
  PACKAGES="${PACKAGES}"

cat << EOF > /openwrt/bin/info.md
${PLATFORM}-${VERSION}-${TARGET}-${SUBTARGET}-${PROFILE}
${PACKAGES}
EOF