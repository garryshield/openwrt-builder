#!/bin/sh
# =============  ==============
echo '========'
pwd

# =============  ==============
echo '========'
env

# =============  ==============
echo '========'

pushd ./packages
curl -sSL -O https://github.com/vernesong/OpenClash/releases/download/v0.46.120/luci-app-openclash_0.46.120_all.ipk
popd

make image \
  PROFILE="${PROFILE}" \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files" \
  PACKAGES="${PACKAGES}"