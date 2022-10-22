#!/bin/bash -ex
name="freetype"
version="2.12.1"
revision="2"

tar xf "${name}-${version}.tar.xz"
patch -d "${name}-${version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

"../${name}-${version}/configure" --host=x86_64-kiwi --prefix=/system --bindir=/system/bin --libdir=/system/lib --includedir=/system/devel/include --datadir=/system/data/freetype --libexecdir=/system/lib --with-zlib=yes --with-bzip2=no --with-png=no --with-harfbuzz=no --with-brotli=no --enable-static=no

sed -i 's|/\* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING \*/|#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING|' ftoption.h

make -j8
make DESTDIR=$(cd ../install; pwd) install

cd ..

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
