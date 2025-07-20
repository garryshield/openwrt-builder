#!/bin/sh

# https://downloads.immortalwrt.org/releases/24.10.2/targets/x86/64/profiles.json
# https://downloads.immortalwrt.org/releases/24.10.2/packages/x86_64/
# https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/profiles.json
# https://downloads.openwrt.org/releases/24.10.2/packages/x86_64/

: <<'COMMENT'
luci
  Depends: libc, luci-light, luci-app-package-manager
luci-light
  Depends: libc, luci-proto-ipv6, luci-app-firewall, luci-mod-admin-full, luci-proto-ppp, luci-theme-bootstrap, rpcd-mod-rrdns, uhttpd, uhttpd-mod-ubus
luci-app-package-manager
  Depends: libc, luci-base
COMMENT

echo '============= docker.sh repositories.conf =============='
cp repositories.conf repositories.conf.bak
if [ "$BUD_PLATFORM" = "openwrt" ]; then
  # TODO 添加 immortalwrt 到 key
  # 禁用签名验证
  sed -i 's/^option check_signature/# option check_signature/' repositories.conf

  # 添加 immortalwrt 的 luci 源
  IMMORTAL_LINE=$(grep '^src/gz openwrt_luci' "repositories.conf" | \
    sed 's|^src/gz openwrt_luci|src/gz immortalwrt_luci|' | \
    sed 's|downloads.openwrt.org|downloads.immortalwrt.org|')
  awk -v new_line="$IMMORTAL_LINE" '
    {
      print $0
      if ($0 ~ /^src\/gz openwrt_telephony/) {
        print new_line
      }
    }
  ' "repositories.conf" > "repositories.conf.tmp" && mv "repositories.conf.tmp" "repositories.conf"
else
  :
fi

# 北大源
# https://mirrors.pku.edu.cn/Help/Openwrt
# https://mirrors.pku.edu.cn/Help/immortalwrt
# 清华源
# https://mirrors.tuna.tsinghua.edu.cn/help/openwrt/
# https://downloads.openwrt.org/releases/24.10.2/packages/x86_64/luci
# https://mirrors.pku.edu.cn/openwrt/releases/24.10.2/packages/x86_64/luci
# https://downloads.immortalwrt.org/releases/24.10.2/packages/x86_64/luci
# https://mirrors.pku.edu.cn/immortalwrt/releases/24.10.2/packages/x86_64/luci
sed -i 's_downloads.openwrt.org_mirrors.pku.edu.cn/openwrt_' repositories.conf
sed -i 's_downloads.immortalwrt.org_mirrors.pku.edu.cn/immortalwrt_' repositories.conf

echo '============= docker.sh base =============='
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci luci-compat"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-package-manager-zh-cn"

BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }curl tree"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }pciutils"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }fdisk block-mount"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }iperf3"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }socat"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }openssh-sftp-server"

# OpenClash 依赖 dnsmasq-full 和 dnsmasq 有冲突
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }dnsmasq-full -dnsmasq"

# luci-app-diskman
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-app-diskman luci-i18n-diskman-zh-cn"

# luci-app-ttyd
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-app-ttyd luci-i18n-ttyd-zh-cn"

# luci-app-ddns
# /usr/bin/ddns --help
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-app-ddns luci-i18n-ddns-zh-cn"

# luci-app-arpbind
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-app-arpbind luci-i18n-arpbind-zh-cn"

echo '============= docker.sh openclash =============='
# https://github.com/vernesong/OpenClash
# https://wiki.metacubex.one/
# 下载 ipk
OPENCLASH_VERSION_URL="https://raw.githubusercontent.com/vernesong/OpenClash/package/master/version"
OPENCLASH_VERSION=$(curl -s "$OPENCLASH_VERSION_URL" | head -n 1 | tr -d 'v')
OPENCLASH_IPK_URL="https://raw.githubusercontent.com/vernesong/OpenClash/package/master/luci-app-openclash_${OPENCLASH_VERSION}_all.ipk"
curl -sSL -o "packages/luci-app-openclash_all.ipk" "$OPENCLASH_IPK_URL"
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }luci-app-openclash"

echo '============= docker.sh adguardhome =============='
# https://github.com/openwrt/packages/tree/master/net/adguardhome
BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }adguardhome"

echo '============= docker.sh make =============='
id
ls -la $(pwd)/openwrt

mkdir -p $(pwd)/openwrt/bin/${BUD_TAG_NAME}
make image \
  BIN_DIR="$(pwd)/openwrt/bin/${BUD_TAG_NAME}" \
  FILES="$(pwd)/openwrt/files" \
  PROFILE="${BUD_PROFILE}" \
  PACKAGES="${BUD_PACKAGES}" \
  ROOTFS_PARTSIZE="300"

ls -la $(pwd)/openwrt/bin/${BUD_TAG_NAME}

echo '============= docker.sh info =============='
cat << EOF > $(pwd)/openwrt/bin/${BUD_TAG_NAME}/info.md
## .env
$(cat $(pwd)/openwrt/files/etc/config/.env)
BUD_PACKAGES=${BUD_PACKAGES}

## .cnf
$(cat $(pwd)/openwrt/files/etc/config/.cnf)
EOF
