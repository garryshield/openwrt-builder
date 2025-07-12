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
  -v ./files:/immortalwrt/files \
  -v ./bin:/immortalwrt/bin \
  immortalwrt/imagebuilder:x86-64-openwrt-24.10.2 \
  make image \
  BIN_DIR="/immortalwrt/bin" \
  FILES="/immortalwrt/files"
```