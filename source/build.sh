#!/bin/bash
#
# SPDX-FileCopyrightText: (C) Alex Smith <alex@alex-smith.me.uk>
# SPDX-License-Identifier: ISC
#

#
# Package build script. Expects to find a script called package.build in the
# current directory, and the package repository in ../../repo/<arch>.
#

pkg_msg() {
    echo -e "\e[0;32m>>>\e[0;1m $*\e[0m"
}

pkg_error() {
    echo -e "\e[0;31m>>>\e[0;1m $*\e[0m"
}

if [ ! -f "package.build" ]; then
    pkg_error "Cannot find 'package.build'"
    exit 1
fi

# We want to stop on errors.
set -e

# TODO: Grab these from .config
pkg_toolchain_target=x86_64-kiwi
pkg_arch=amd64

source "package.build"

if [ -z "${pkg_name}" -o -z "${pkg_version}" -o -z "${pkg_revision}" ]; then
    pkg_error "Package metadata is not set correctly"
    exit 1
fi

pkg_msg "Building ${pkg_name}-${pkg_version}-${pkg_revision}"

pkg_repo_dir="../../repo/${pkg_arch}"

if [ ! -d "$pkg_repo_dir" ]; then
    pkg_error "Cannot find package repository '${pkg_repo_dir}'"
fi

pkg_repo_dir="$(cd "../../repo/${pkg_arch}"; pwd)"

pkg_source_dir="$(pwd)"
if [ ! -d "${pkg_source_dir}" ]; then
    # Always a good idea to be careful if we're gonna feed a path based on this
    # to rm -rf...
    pkg_error "Could not get current directory"
    exit 1
fi

# Download separately to work directory so we can re-use downloaded files.
pkg_download_dir="${pkg_source_dir}/download"
pkg_work_dir="${pkg_source_dir}/work"
pkg_install_dir="${pkg_work_dir}/install"

# Clean existing work directory.
if [ -d "$pkg_work_dir" ]; then
    pkg_msg "Cleaning existing work directory '${pkg_work_dir}'"
    rm -rf "$pkg_work_dir"
fi

mkdir -p "${pkg_download_dir}"
mkdir "${pkg_work_dir}"
mkdir "${pkg_install_dir}"

# Download sources.
for source in "${pkg_sources[@]}"; do
    file_name="${pkg_download_dir}/$(basename "$source")"
    if [ ! -f "$file_name" ]; then
        pkg_msg "Downloading ${source}"
        curl -o "$file_name" "$source"
    fi
done

# Update sysroot.
pkg_msg "Updating sysroot"
scons -C ../../.. IGNORE_SUBMODULES=1 sysroot

# Build the package.
pkg_msg "Running build function"
cd "$pkg_work_dir"
set -x
pkg_build
set +x

# Archive it to the repository.
pkg_archive="${pkg_repo_dir}/${pkg_name}-${pkg_version}-${pkg_revision}.bin.tar.xz"
pkg_msg "Creating package archive '${pkg_archive}'"
tar -cvJf "$pkg_archive" -C "${pkg_install_dir}" .

pkg_msg "Done!"
