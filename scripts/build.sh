#!/bin/sh
# =============  ==============
echo '========'
pwd

# =============  ==============
echo '========'
env

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

echo '1' > /openwrt/bin/1.txt
echo '2' > /openwrt/bin/2.txt

cat << EOF > /openwrt/bin/info.md
${PACKAGES}
$(pwd)
EOF

ls -la
