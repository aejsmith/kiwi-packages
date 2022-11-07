#!/bin/bash -ex
name="ncurses"
version="6.3"
revision="3"

tar xf "${name}-${version}.tar.gz"
patch -d "${name}-${version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

"../${name}-${version}/configure" --host=x86_64-kiwi --prefix=/system --bindir=/system/bin --libdir=/system/lib --includedir=/system/devel/include --datadir=/system/data/ncurses --libexecdir=/system/lib --disable-nls --disable-mouse --without-cxx-binding --with-shared --without-manpages --without-normal --without-debug --with-termlib
make -j8
make DESTDIR="$(cd ../install; pwd)" install

cd ..

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
