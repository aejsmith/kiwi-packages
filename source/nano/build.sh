#!/bin/bash -ex
name="nano"
version="6.4"
revision="2"

tar xf "${name}-${version}.tar.xz"

patch -d "${name}-${version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

# TODO: Remove LIBS once we link to libkernel by default.
LIBS="-lkernel" "../${name}-${version}/configure" --host=x86_64-kiwi --prefix=/system --datadir=/system/data --libexecdir=/system/lib --disable-mouse --disable-speller --disable-nls --disable-utf8 ac_cv_header_langinfo_h=0
make -j8
make DESTDIR="$(cd ../install; pwd)" install

cd ..

# Remove man pages and texinfo files
rm -rf install/system/share

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${version}"
