# openwrt-builder


```
docker run --rm -it immortalwrt/imagebuilder:x86-64-openwrt-24.10.2

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make help

docker run --rm immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make info
```

```
docker run --rm \
  --user root \
  -v ./files:/openwrt/files \
  -v ./bin:/openwrt/bin \
  immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make image \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files"
```

```
docker run --rm \
  --user root \
  -v ./files:/openwrt/files \
  -v ./bin:/openwrt/bin \
  openwrt/imagebuilder:x86-64-24.10.2 \
  make image \
  BIN_DIR="/openwrt/bin" \
  FILES="/openwrt/files"
```

```
gzip -d openwrt-24.10.2-x86-64-generic-rootfs.tar.gz
docker import openwrt-24.10.2-x86-64-generic-rootfs.tar openwrt_tmp:24.10.2
docker run -it openwrt_tmp:24.10.2 /bin/sh
```