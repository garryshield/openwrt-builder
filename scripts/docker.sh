#!/bin/sh

# =============  ==============
echo '========'

curl -sSL -o ./packages/luci-app-openclash_0.46.120_all.ipk https://github.com/vernesong/OpenClash/releases/download/v0.46.120/luci-app-openclash_0.46.120_all.ipk

ls -la ./packages

PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES dnsmasq-full -dnsmasq"

# make image \
#   PROFILE="${PROFILE}" \
#   BIN_DIR="/openwrt/bin" \
#   FILES="/openwrt/files" \
#   PACKAGES="${PACKAGES}"

cat << EOF > /openwrt/bin/info.md
${PACKAGES}
EOF