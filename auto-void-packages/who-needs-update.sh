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

NEEDS_UPDATE="needs_update.txt"
[ -f "$NEEDS_UPDATE" ] && rm "$NEEDS_UPDATE"

CONTRIBUTED_TO_FILE="contributed-to.txt"

VOID_UPDATES_URL="https://repo-fi.voidlinux.org/void-updates/void-updates.txt"
VOID_UPDATES=$(curl --silent "$VOID_UPDATES_URL")

# for each package that needs an update put it in the file
# for every package, print its name with an icon depending on its status
# x for not needing an update
# v for needing one
while read -r PKG;
do
	# checks if there's a # at the beginning of the line
	# if so, skip the current iteration
	echo "$PKG" | grep -q '^#' && continue

	printf_magenta "$PKG"
	UPDATES=$(echo "$VOID_UPDATES" | grep -e "^$PKG ")
	if [ -z "$UPDATES" ];
	then
		printf_red "✖"
	else
		printf_green "✔️"
		echo "$UPDATES" >> "$NEEDS_UPDATE"
	fi
done <$CONTRIBUTED_TO_FILE

# print the file containing the packages needding an update
[ -f "$NEEDS_UPDATE" ] && bat $NEEDS_UPDATE
