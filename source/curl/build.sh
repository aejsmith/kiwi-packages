#!/bin/bash -ex
name="curl"
version="7.86.0"
revision="2"

tar xf "${name}-${version}.tar.xz"
patch -d "${name}-${version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

# TODO: Enable socketpair when we support it and AF_UNIX sockets.
"../${name}-${version}/configure" --host=x86_64-kiwi --prefix=/system --bindir=/system/bin --libdir=/system/lib --includedir=/system/devel/include --datadir=/system/data/curl --libexecdir=/system/lib --enable-static=no --with-ssl --disable-ipv6 --disable-socketpair
make -j8
make DESTDIR="$(cd ../install; pwd)" install

cd ..

rm -rf install/system/share

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
