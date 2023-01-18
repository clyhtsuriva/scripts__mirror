#!/usr/bin/env bash
#Clyhtsuriva


helpy(){
printf "command: %s <package> <version>\n" "$0"
printf "package: package name\n"
printf "version: version update\n"
}


[ -z "$1" ] || [ -z "$2" ] && helpy && exit 1
PKG="$1"
VER="$2"
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

ARCHS_FILE="$HOME/workbench/auto-void-packages/architectures.txt"
[ -f "$ARCHS_FILE" ] && rm -v "$ARCHS_FILE"
./xbps-src -a armv7l pkg "$PKG" && echo "  - armv7l" >> "$ARCHS_FILE"
./xbps-src -a armv6l-musl pkg "$PKG" && echo "  - armv6l-musl" >> "$ARCHS_FILE"
./xbps-src -a aarch64-musl pkg "$PKG" && echo "  - aarch64-musl" >> "$ARCHS_FILE"
./xbps-src pkg "$PKG" || exit 1

xi -S --repository="hostdir/binpkgs/$PKG-update" "$PKG" && $PKG --version

popd || exit 1
