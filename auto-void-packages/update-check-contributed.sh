#!/usr/bin/env bash

# Clyhsuriva

### Colours

NORMAL=$(tput sgr0)

printf_red(){
RED=$(tput setaf 1)
	printf "%s%s%s\n" "$RED" "$1" "$NORMAL"
}

printf_green(){
GREEN=$(tput setaf 2)
BOLD=$(tput bold)
	printf "%s%s%s%s\n" "$GREEN" "$BOLD" "$1" "$NORMAL"
}

printf_magenta(){
MAGENTA=$(tput setaf 5)
	printf "%s[%s]%s" "$MAGENTA" "$1" "$NORMAL"
}

####

WORKBENCH_FOLDER="$HOME/workbench"

NEEDS_UPDATE="$WORKBENCH_FOLDER/auto-void-packages/needs_update.txt"
[ -f "$NEEDS_UPDATE" ] && rm "$NEEDS_UPDATE"

CONTRIBUTED_TO_FILE="$WORKBENCH_FOLDER/auto-void-packages/contributed-to.txt"
VOID_PACKAGES_FOLDER="$WORKBENCH_FOLDER/void-packages"

# for each package that needs an update put it in the file
# for every package, print its name with an icon depending on its status
# x for not needing an update
# v for needing one
pushd "$VOID_PACKAGES_FOLDER" || exit 1
while read -r PKG;
do
	printf_magenta "$PKG"
	UPDATES=$(./xbps-src update-check "$PKG")
	if [ -z "$UPDATES" ];
	then
		printf_red "✖"
	else
		printf_green "✔️"
		echo "$UPDATES" >> "$NEEDS_UPDATE"
	fi
done <"$CONTRIBUTED_TO_FILE"
popd || exit 1

# print the file containing the packages needing an update
[ -f "$NEEDS_UPDATE" ] && bat "$NEEDS_UPDATE"
