```
TAGS_NAME="openwrt"
REPO_URL="https://github.com/openwrt/openwrt"
REPO_BRANCH="master"
git clone --single-branch --depth=1 --branch=${REPO_BRANCH} ${REPO_URL} ./code/${TAGS_NAME}


TAGS_NAME="lede"
REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
git clone --single-branch --depth=1 --branch=${REPO_BRANCH} ${REPO_URL} ./code/${TAGS_NAME}


TAGS_NAME="immortalwrt"
REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="master"
git clone --single-branch --depth=1 --branch=${REPO_BRANCH} ${REPO_URL} ./code/${TAGS_NAME}

```

```
./scripts/feeds update -a
./scripts/feeds install -a
make download -j$(nproc)
make -j$(nproc) || make -j1 || make -j1 V=s
```