# openwrt-builder

```
docker run --rm -it immortalwrt/imagebuilder:x86-64-openwrt-24.10.2
/home/build/immortalwrt

docker run --rm -it openwrt/imagebuilder:x86-64-24.10.2
/builder

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make help

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make info
```

```
PACKAGES=$(cat ./config/packages.config | tr -s "\n" " ")
docker run --rm \
  --user root \
  -v ./files:/openwrt/files \
  -v ./bin:/openwrt/bin \
  immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make image \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files" \
  PACKAGES="${PACKAGES}"
```

```
PACKAGES=$(cat ./config/packages.config | tr -s "\n" " ")
docker run --rm \
  --user root \
  -v ./files:/openwrt/files \
  -v ./bin:/openwrt/bin \
  openwrt/imagebuilder:x86-64-24.10.2 \
  make image \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files" \
  PACKAGES="${PACKAGES}"
```

```
gzip -dkf openwrt-24.10.2-x86-64-generic-rootfs.tar.gz
docker import openwrt-24.10.2-x86-64-generic-rootfs.tar openwrt_tmp:24.10.2
docker run --rm -it openwrt_tmp:24.10.2 /bin/sh
```

```bash
gzip -dkvqf openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
scp openwrt-24.10.2-x86-64-generic-ext4-combined.img pve:/var/lib/vz/template/iso/
ssh pve '
  qm stop 101
  qm destroy 101 --purge --destroy-unreferenced-disks

  qm create 101 --core 2 --memory 2048 --net0 virtio,bridge=vmbr0,firewall=1 --scsihw virtio-scsi-pci --name Openwrt
  qm set 101 --scsi0 local:0,import-from=/var/lib/vz/template/iso/openwrt-24.10.2-x86-64-generic-ext4-combined.img
  qm set 101 --boot order=scsi0
  qm disk resize 101 scsi0 +256M
  qm config 101
'


gzip -dkvqf immortalwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
scp immortalwrt-24.10.2-x86-64-generic-ext4-combined.img pve:/var/lib/vz/template/iso/
ssh pve '
  qm stop 102
  qm destroy 102 --purge --destroy-unreferenced-disks

  qm create 102 --core 2 --memory 2048 --net0 virtio,bridge=vmbr0,firewall=1 --scsihw virtio-scsi-pci --name Immortalwrt
  qm set 102 --scsi0 local:0,import-from=/var/lib/vz/template/iso/immortalwrt-24.10.2-x86-64-generic-ext4-combined.img
  qm set 102 --boot order=scsi0
  qm disk resize 102 scsi0 +256M
  qm config 102
'
```