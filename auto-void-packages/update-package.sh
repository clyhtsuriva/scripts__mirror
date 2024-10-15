#!/usr/bin/env bash
#Clyhtsuriva


helpy(){
	printf "command: %s <package> <version> [path]\n" "$0"
printf "package: package name\n"
printf "version: version update\n"
printf "path (optional): path of architectures file, defaults to '\$HOME/workbench/auto-void-packages/architectures.txt'\n"
}


[ -z "$1" ] || [ -z "$2" ] && helpy && exit 1
PKG="$1"
VER="$2"
archs_fp="${3:-$HOME/workbench/auto-void-packages/architectures.txt}"
printf "Updating %s to %s.\n" "$PKG" "$VER"

pushd ~/workbench/void-packages || exit 1

git checkout master
git checkout -b "$PKG-update" || ( \
	git checkout master &&\
	git branch -D "$PKG-update" && \
	git checkout -b "$PKG-update" ) || \
	exit 1

sed -i "s/version=.*/version=$VER/g" "srcpkgs/$PKG/template"
sed -i "s/revision=.*/revision=1/g" "srcpkgs/$PKG/template"

xgensum -f -i "$PKG" ; xgensum -f -i "$PKG" || exit 1

[ -f "$archs_fp" ] && rm -v "$archs_fp"
./xbps-src -a armv7l pkg "$PKG" && echo "  - armv7l" >> "$archs_fp"
./xbps-src -a armv6l-musl pkg "$PKG" && echo "  - armv6l-musl" >> "$archs_fp"
./xbps-src -a aarch64-musl pkg "$PKG" && echo "  - aarch64-musl" >> "$archs_fp"
./xbps-src pkg "$PKG" || exit 1

xi -S --repository="hostdir/binpkgs/$PKG-update" "$PKG" && $PKG --version

popd || exit 1
