#!/bin/bash

# https://downloads.immortalwrt.org/releases/24.10.2/targets/x86/64/profiles.json
# https://downloads.immortalwrt.org/releases/24.10.2/packages/x86_64/
# https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/profiles.json
# https://downloads.openwrt.org/releases/24.10.2/packages/x86_64/

echo '============= docker.sh info =============='
id

curl -s https://ipinfo.io
echo

: <<'COMMENT'
make package_depends PACKAGE="<pkg>"
make package_whatdepends PACKAGE="<pkg>"

luci
  Depends: libc, luci-light, luci-app-package-manager
luci-light
  Depends: libc, luci-proto-ipv6, luci-app-firewall, luci-mod-admin-full, luci-proto-ppp, luci-theme-bootstrap, rpcd-mod-rrdns, uhttpd, uhttpd-mod-ubus
luci-app-package-manager
  Depends: libc, luci-base
COMMENT

echo '============= docker.sh repositories =============='
# 24 使用 opkg 
# 25 使用 apk

# 清华源
# https://mirrors.tuna.tsinghua.edu.cn/help/openwrt/

# 北大源
# https://mirrors.pku.edu.cn/Help/Openwrt
# https://mirrors.pku.edu.cn/Help/immortalwrt

# https://downloads.openwrt.org/releases/24.10.2/packages/x86_64/luci
# https://mirrors.pku.edu.cn/openwrt/releases/24.10.2/packages/x86_64/luci

# https://downloads.immortalwrt.org/releases/24.10.2/packages/x86_64/luci
# https://mirrors.pku.edu.cn/immortalwrt/releases/24.10.2/packages/x86_64/luci

# MirrorZ 
# https://help.mirrors.cernet.edu.cn/openwrt/
# https://help.mirrors.cernet.edu.cn/immortalwrt/

if [ -f "repositories.conf" ]; then
  PKG_MGR="opkg"
else
  PKG_MGR="apk"
fi

file_list=(
  "repositories.conf"
  "repositories"
)
for file in "${file_list[@]}"; do
  echo $file
  if [ -f "$file" ]; then
    cp "$file" "${file}.bak"
    sed -i 's_https\?://downloads.openwrt.org_https://mirrors.cernet.edu.cn/openwrt_' "$file"
    sed -i 's_https\?://downloads.immortalwrt.org_https://mirrors.cernet.edu.cn/immortalwrt_' "$file"
    sed -i 's_https\?://mirrors.vsean.net/openwrt_https://mirrors.cernet.edu.cn/immortalwrt_' "$file"
    cat $file
  fi
done

echo '============= docker.sh base =============='
PACKAGES=(
  curl
  tree
  pciutils
  fdisk
  block-mount
  resize2fs
  losetup
  iperf3
  socat
  openssh-sftp-server
)

PACKAGES+=(
  luci
  luci-compat
  luci-i18n-base-zh-cn
  luci-i18n-firewall-zh-cn
  luci-i18n-package-manager-zh-cn
  luci-i18n-filemanager-zh-cn
  luci-i18n-ttyd-zh-cn
)

# openclash 依赖 dnsmasq-full 和 dnsmasq 有冲突
PACKAGES+=(
  dnsmasq-full
  -dnsmasq
)

# luci-app-ddns
# /usr/bin/ddns --help
# https://github.com/openwrt/luci/tree/master/applications/luci-app-ddns
# https://github.com/openwrt/packages/blob/master/net/ddns-scripts
PACKAGES+=(
  luci-i18n-ddns-zh-cn
)

# https://github.com/openwrt/packages/tree/master/net/adguardhome
PACKAGES+=(
  adguardhome
)

if [[ "$BUD_PLATFORM" == "immortalwrt" ]]; then
  # luci-app-diskman
  PACKAGES+=(
    luci-i18n-diskman-zh-cn
  )

  # luci-app-arpbind
  PACKAGES+=(
    luci-i18n-arpbind-zh-cn
  )

  # luci-app-openclash
  # https://wiki.metacubex.one/
  # https://github.com/vernesong/OpenClash
  PACKAGES+=(
    luci-app-openclash
  )
fi

if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
  :
fi

BUD_PACKAGES="${BUD_PACKAGES:+$BUD_PACKAGES }${PACKAGES[*]}"

echo $BUD_PACKAGES

ls -lah ./packages

echo '============= docker.sh make =============='

mkdir -p ./openwrt/bin/${BUD_TAG_NAME}

make image \
  BIN_DIR="$(pwd)/openwrt/bin/${BUD_TAG_NAME}" \
  FILES="$(pwd)/openwrt/files" \
  PROFILE="${BUD_PROFILE}" \
  PACKAGES="${BUD_PACKAGES}" \
  ROOTFS_PARTSIZE="${BUD_ROOTFS_PARTSIZE}"

echo '============= docker.sh info =============='
cat << EOF > ./openwrt/bin/${BUD_TAG_NAME}/info.md
## .env
$(cat ./openwrt/files/etc/config/.env)
BUD_PACKAGES=${BUD_PACKAGES}

## .cnf
$(cat ./openwrt/files/etc/config/.cnf)
EOF

ls -lah ./openwrt/bin/${BUD_TAG_NAME}