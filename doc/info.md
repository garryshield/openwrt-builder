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
gzip -dkvqf openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
scp openwrt-24.10.2-x86-64-generic-ext4-combined.img pve:/var/lib/vz/template/iso/
ssh pve '
  qm unlock 101
  qm stop 101
  qm destroy 101 --purge --destroy-unreferenced-disks

  qm create 101 --name Openwrt
  qm set 101 --core 2 --memory 2048 
  qm set 101 --net0 virtio,bridge=vmbr0,firewall=1 
  qm set 101 --scsihw virtio-scsi-pci 
  qm set 101 --scsi0 local:0,import-from=/var/lib/vz/template/iso/openwrt-24.10.2-x86-64-generic-ext4-combined.img
  qm disk resize 101 scsi0 +256M
  qm set 101 --boot order=scsi0
  qm set 101 --hostpci0 0000:05:00
  qm set 101 --hostpci1 0000:06:00
  qm config 101
  qm start 101
'
```

```bash
gzip -dkvqf immortalwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
scp immortalwrt-24.10.2-x86-64-generic-ext4-combined.img pve:/var/lib/vz/template/iso/
ssh pve '
  qm unlock 102
  qm stop 102
  qm destroy 102 --purge --destroy-unreferenced-disks

  qm create 102 --name Immortalwrt
  qm set 102 --core 2 --memory 2048 
  qm set 102 --net0 virtio,bridge=vmbr0,firewall=1
  qm set 102 --scsihw virtio-scsi-pci 
  qm set 102 --scsi0 local:0,import-from=/var/lib/vz/template/iso/immortalwrt-24.10.2-x86-64-generic-ext4-combined.img
  qm disk resize 102 scsi0 +256M
  qm set 102 --boot order=scsi0
  qm set 102 --hostpci0 0000:05:00
  qm set 102 --hostpci1 0000:06:00
  qm config 102
  qm start 102
'
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