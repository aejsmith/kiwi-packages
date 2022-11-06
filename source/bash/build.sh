#!/bin/bash -ex
name="bash"
version="5.2.2"
revision="2"

base_version="5.2"
patches=(bash52-001 bash52-002)

tar xf "${name}-${base_version}.tar.gz"

for patch in ${patches[@]}; do
    patch -d "${name}-${base_version}" -Np0 -i "../${patch}"
done

patch -d "${name}-${base_version}" -Np1 -i "../${name}-${version}-kiwi.patch"

mkdir build install
cd build

"../${name}-${base_version}/configure" --host=x86_64-kiwi --prefix=/system --datadir=/system/data/bash --libexecdir=/system/lib --disable-nls --without-bash-malloc ac_cv_func_dlopen=no
make -j8
make DESTDIR="$(cd ../install; pwd)" install

cd ..

# Remove man pages and texinfo files
rm -rf install/system/share

# sh symlink.
ln -s bash install/system/bin/sh

tar -cvJf "${name}-${version}-${revision}.bin.tar.xz" -C install .

rm -rf build install "${name}-${base_version}"
