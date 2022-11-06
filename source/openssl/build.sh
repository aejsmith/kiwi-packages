#!/bin/bash -ex
name="openssl"
version="3.0.7"
revision="2"

tar xf "${name}-${version}.tar.gz"
patch -d "${name}-${version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

"../${name}-${version}/Configure" --prefix=/system --cross-compile-prefix=x86_64-kiwi- --openssldir=/system/etc/openssl shared enable-ec_nistp_64_gcc_128 no-tests kiwi-x86_64
make -j8
make DESTDIR=$(cd ../install; pwd) install_sw install_ssldirs

cd ..

rm -rf install/system/lib/*.a install/system/lib/pkgconfig
mkdir -p install/system/devel
mv install/system/include install/system/devel

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
