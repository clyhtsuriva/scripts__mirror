#!/usr/bin/env bash
#Clyhtsuriva


helpy(){
printf "command: %s <package> <version> <tested>\n" "$0"
printf "package: package name\n"
printf "version: version update\n"
printf "tested: yes/briefly/no\n"
}


[ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] && helpy && exit 1
PKG="$1"
VER="$2"
TESTED="$3"
printf "Updating %s to %s.\n" "$PKG" "$VER"

pushd ~/workbench/void-packages || exit 1

git add "srcpkgs/$PKG" && \
	git commit -m "$PKG: update to $VER" && \
	git push origin "$PKG-update"

ARCHS=$(/bin/cat "$HOME/workbench/auto-void-packages/architectures.txt")

gh pr create \
	--title "$PKG: update to $VER" \
	--body "#### Testing the changes
- I tested the changes in this PR: **$TESTED**

#### Local build testing
- I built this PR locally for my native architecture, x86_64
- I crossbuilded this PR locally for these architectures:
$ARCHS" \
	--base master \
	--head "clyhtsuriva:$PKG-update"

popd || exit 1
