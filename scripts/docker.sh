#!/bin/sh

echo '=============  =============='

PACKAGES="${PACKAGES:+$PACKAGES }curl"
PACKAGES="${PACKAGES:+$PACKAGES }luci-app-openclash"

if [ "$PLATFORM" = "openwrt" ]; then
  curl -sSL -o ./packages/luci-app-openclash_0.46.133_all.ipk https://raw.githubusercontent.com/vernesong/OpenClash/package/master/luci-app-openclash_0.46.133_all.ipk
  PACKAGES="${PACKAGES:+$PACKAGES }luci luci-compat luci-i18n-base-zh-cn"
  PACKAGES="${PACKAGES:+$PACKAGES }dnsmasq-full -dnsmasq"
fi

mkdir -p /openwrt/files/etc/openclash/core
META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
wget -qO- $META_URL | tar xzO > /openwrt/files/etc/openclash/core/clash_meta
chmod +x /openwrt/files/etc/openclash/core/clash_meta

# https://mirrors.tuna.tsinghua.edu.cn/help/openwrt/
sed -i 's_https\?://downloads.openwrt.org_https://mirrors.tuna.tsinghua.edu.cn/openwrt_' repositories.conf

make image \
  BIN_DIR="/openwrt/bin/${TAG_NAME}" \
  FILES="/openwrt/files" \
  PROFILE="${PROFILE}" \
  PACKAGES="${PACKAGES}"

cat << EOF > /openwrt/bin/${TAG_NAME}/info.md
${TAG_NAME}
${PACKAGES}
EOF