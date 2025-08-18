```bash
docker run --rm -it immortalwrt/imagebuilder:x86-64-openwrt-24.10.2
# /home/build/immortalwrt

docker run --rm -it openwrt/imagebuilder:x86-64-24.10.2
# /builder

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make help

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make info
```

```bash
gzip -dkf openwrt-24.10.2-x86-64-generic-rootfs.tar.gz
docker import openwrt-24.10.2-x86-64-generic-rootfs.tar openwrt_tmp:24.10.2
docker run --rm -it openwrt_tmp:24.10.2 /bin/sh
```

```bash
IMG_FIL="immortalwrt-24.10.2-x86-64-generic-ext4-combined.img.gz"
VM_NAME="Immortalwrt"
IMG_FIL="openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz"
VM_NAME="Openwrt"
VM_ID=100
IMG="${IMG_FIL%.gz}"
gzip -dkvqf ${IMG_FIL}
scp ${IMG} pve:/var/lib/vz/template/iso/
ssh pve bash -s <<EOF
  # qm unlock ${VM_ID}
  # qm stop ${VM_ID}
  # qm destroy ${VM_ID} --purge --destroy-unreferenced-disks

  # qm create ${VM_ID} --name ${VM_NAME}
  # qm set ${VM_ID} --core 2 --memory 2048
  # qm set ${VM_ID} --net0 virtio,bridge=vmbr0,firewall=1
  # qm set ${VM_ID} --scsihw virtio-scsi-pci
  # qm set ${VM_ID} --scsi0 local:0,import-from=/var/lib/vz/template/iso/${IMG}
  # qm disk resize ${VM_ID} scsi0 +256M
  # qm set ${VM_ID} --boot order=scsi0
  # qm set ${VM_ID} --hostpci0 0000:05:00
  # qm set ${VM_ID} --hostpci1 0000:06:00
  # qm config ${VM_ID}
  # qm start ${VM_ID}
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
