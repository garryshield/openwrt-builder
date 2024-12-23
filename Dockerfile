FROM debian:12

WORKDIR /usr/src/app

# https://mirrors.ustc.edu.cn/help/debian.html
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
RUN apt-get update

# timezone
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
ENV TZ=Asia/Shanghai

# locale
RUN apt-get install -y locales
RUN sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# https://github.com/coolsnowwolf/lede
RUN apt-get update -y
RUN apt-get full-upgrade -y
RUN apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libncurses-dev libpython3-dev libreadline-dev \
libssl-dev libtool llvm lrzsz genisoimage msmtp ninja-build p7zip p7zip-full patch pkgconf python3 \
python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
uglifyjs unzip vim wget xmlto xxd zlib1g-dev

# cleanup
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# user & group
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} garry \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash garry
USER garry

CMD ["bash"]
