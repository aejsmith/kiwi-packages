#!/bin/bash -ex
name="zlib"
version="1.2.13"
revision="1"

tar xf "${name}-${version}.tar.gz"

mkdir build install
cd build

LDSHAREDLIBC="-lsystem" CROSS_PREFIX=x86_64-kiwi- ../zlib-1.2.13/configure --prefix=/system --includedir=/system/devel/include
make -j8
make DESTDIR="$(cd ../install; pwd)" install

cd ..

rm -rf install/system/share
rm -f install/system/lib/*.a

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
