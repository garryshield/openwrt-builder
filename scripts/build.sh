#!/bin/sh
# =============  ==============
echo '========'
pwd

# =============  ==============
echo '========'
env

# =============  ==============
echo '========'
make image \
  PROFILE="${PROFILE}" \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files" \
  PACKAGES="${PACKAGES}"