
#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# wslay
cd $WORKSPACE
git clone https://github.com/tatsuhiro-t/wslay.git
cd wslay
autoreconf -i
automake
autoconf
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr
make -C lib
make -C lib install

# brotli
cd $WORKSPACE
git clone https://github.com/google/brotli.git
cd brotli
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF ..
ninja
ninja install

# h2o
cd $WORKSPACE
git clone https://github.com/h2o/h2o.git
cd h2o
mkdir build
cd build
cmake .. -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local/h2omm -DWITH_MRUBY=on -DCMAKE_EXE_LINKER_FLAGS="-static --static -no-pie -s"
sed -i 's/libcrypto.so/libcrypto.a/g' build.ninja
sed -i 's/libssl.so/libssl.a/g' build.ninja
sed -i 's/libz.so/libz.a/g' build.ninja
ninja
ninja install


cd /usr/local
tar vcJf ./h2omm.tar.xz h2omm

mv ./h2omm.tar.xz /work/artifact/
