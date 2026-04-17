https://downloads.immortalwrt.org/
https://firmware-selector.immortalwrt.org/

https://downloads.openwrt.org/
https://firmware-selector.openwrt.org/

https://openwrt.org/docs/guide-user/additional-software/imagebuilder
https://openwrt.org/docs/guide-developer/imagebuilder_frontends

https://chinanet.mirrors.ustc.edu.cn/immortalwrt/
https://chinanet.mirrors.ustc.edu.cn/openwrt/

```bash
# openwrt
# 24.10.6 
# 25.12.2

# immortalwrt 
# 24.10.5

list=(
  "openwrt/imagebuilder:x86-64-24.10.6"
  "openwrt/rootfs:x86-64-24.10.6"

  "openwrt/imagebuilder:x86-64-25.12.2"
  "openwrt/rootfs:x86-64-25.12.2"
  
  "immortalwrt/imagebuilder:x86-64-openwrt-24.10.5"
  "immortalwrt/rootfs:x86-64-openwrt-24.10.2"

  "immortalwrt/imagebuilder:x86-64-openwrt-24.10.5"
  "immortalwrt/rootfs:x86-64-openwrt-24.10.5"

  "immortalwrt/imagebuilder:x86-64-openwrt-25.12.0-rc1"
  "immortalwrt/rootfs:x86-64-openwrt-25.12.0-rc1"
)
for item in "${list[@]}"; do
  sudo docker pull "${item}"
done

docker pull openwrt/imagebuilder:x86-64-25.12.2
docker pull openwrt/rootfs:x86-64-25.12.2

docker pull quay.io/openwrt/imagebuilder:x86-64-25.12.2
docker pull ghcr.io/openwrt/rootfs:x86-64-25.12.2

docker pull ghcr.io/openwrt/imagebuilder:x86-64-25.12.2
docker pull quay.io/openwrt/rootfs:x86-64-25.12.2
```

```bash
docker run --rm openwrt/imagebuilder:x86-64-24.10.6 cat repositories.conf
docker run --rm openwrt/rootfs:x86-64-24.10.6 cat /etc/opkg/distfeeds.conf

docker run --rm openwrt/imagebuilder:x86-64-25.12.2 cat repositories
docker run --rm openwrt/rootfs:x86-64-25.12.2 cat /etc/apk/repositories.d/distfeeds.list

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.5 cat repositories.conf
docker run --rm immortalwrt/rootfs:x86-64-openwrt-24.10.5 cat /etc/opkg/distfeeds.conf

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-25.12.0-rc1 cat repositories
docker run --rm immortalwrt/rootfs:x86-64-openwrt-25.12.0-rc1 cat /etc/apk/repositories.d/distfeeds.list
```

```bash
docker run --rm -it openwrt/imagebuilder:x86-64-24.10.6
# /builder

docker run --rm -it immortalwrt/imagebuilder:x86-64-openwrt-24.10.5
# /home/build/immortalwrt

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.5 \
  make help

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.5 \
  make info
```

```bash
gzip -dkf openwrt-24.10.6-x86-64-generic-rootfs.tar.gz
docker import openwrt-24.10.6-x86-64-generic-rootfs.tar openwrt_tmp:24.10.2
docker run --rm -it openwrt_tmp:24.10.2 /bin/sh
```

```bash
IMG_FIL="immortalwrt-24.10.5-x86-64-generic-ext4-combined.img.gz"
VM_NAME="Immortalwrt"
# IMG_FIL="openwrt-24.10.6-x86-64-generic-ext4-combined.img.gz"
# VM_NAME="Openwrt"
VM_ID=101
IMG_NAM="${IMG_FIL%.gz}"
gzip -dkvqf ${IMG_FIL}
# PVE_SSH="pve"
PVE_SSH="root@10.10.1.10"
ssh ${PVE_SSH} bash -s <<EOF
  qm list
EOF
scp ${IMG_NAM} ${PVE_SSH}:/var/lib/vz/template/iso/
ssh ${PVE_SSH} bash -s <<EOF
  qm unlock ${VM_ID}
  qm stop ${VM_ID}
  qm destroy ${VM_ID} --purge --destroy-unreferenced-disks

  qm create ${VM_ID} --name ${VM_NAME}
  qm set ${VM_ID} --core 2 --memory 2048
  qm set ${VM_ID} --net0 virtio,bridge=vmbr0,firewall=1
  qm set ${VM_ID} --scsihw virtio-scsi-pci
  qm set ${VM_ID} --scsi0 local:0,import-from=/var/lib/vz/template/iso/${IMG_NAM}
  qm disk resize ${VM_ID} scsi0 +256M
  qm set ${VM_ID} --boot order=scsi0
  qm set ${VM_ID} --hostpci0 0000:05:00
  qm set ${VM_ID} --hostpci1 0000:06:00
  qm config ${VM_ID}
  qm start ${VM_ID}
EOF
```

```bash
lspci

# 查看网卡对应的 PCI 地址
readlink -f /sys/class/net/eth0/device
# /sys/devices/pci0000:00/0000:00:12.0/virtio2
lspci -s 0000:00:12.0

for iface in /sys/class/net/*; do
  name=$(basename "$iface")
  if [ -e "$iface/device" ] && echo "$name" | grep -Eq '^eth|^en'; then
    echo $iface
    echo $name

    add=$(readlink -f $iface/device)
    echo $add
    pci=$(echo $add | awk -F'/' '{print $5}')
    echo $pci

    slot=$(lspci -s $pci)
    echo $slot

    echo
  fi
done
```
