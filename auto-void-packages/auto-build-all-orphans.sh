#!/usr/bin/env bash
#
# Clyhsuriva
#
#   __          _______   _____
#   \ \        / /_   _| |  __ \
#    \ \  /\  / /  | |   | |__) |
#     \ \/  \/ /   | |   |  ___/
#      \  /\  /   _| |_ _| |_
#       \/  \(_) |_____(_)_(_)
#

###

# All variables must be declared.
set -o nounset
# Truncating existing non-empty files must be explicit,
# so instead of `echo "text" > file` you must use `echo "text" >| file`.
set -o noclobber
# Avoids translation of commands messages, numeric and date format, string expansion and sorting.
export LC_ALL=C
# This provides a more readable output to follow when tracing with `set -x`.
export PS4=' (${BASH_SOURCE##*/}::${FUNCNAME[0]:-main}::$LINENO)  '

###

### VARIABLES ###

typeset NORMAL=""
typeset GREEN=""
typeset BOLD=""
typeset MAGENTA=""

typeset yn
typeset -i spinner_pid

typeset void_updates_url=""
typeset void_updates_content=""
typeset orphan_packages=""
typeset orphan_packages_sorted=""
typeset package=""

typeset -A pkgs_to_update=()

###

### COLOURS ###

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

### FUNCTIONS

function yes_or_no {
    while true; do
        read -rp "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

function start_spinner {
    set +m
    echo -n "$1         "
    { while : ; do for X in '  •     ' '   •    ' '    •   ' '     •  ' '      • ' '     •  ' '    •   ' '   •    ' '  •     ' ' •      ' ; do echo -en "\b\b\b\b\b\b\b\b$X" ; sleep 0.1 ; done ; done & } 2>/dev/null
    spinner_pid=$!
}

function stop_spinner {
    { kill -9 "$spinner_pid" && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
}

###

### MAIN ###

void_updates_url="https://repo-fi.voidlinux.org/void-updates/void-updates.txt"
void_updates_content=$(curl --silent "$void_updates_url")
orphan_packages=$(echo "$void_updates_content" | sed -n '/orphan@voidlinux.org/,/@/p' | grep -v '^--' | grep -v '@')
orphan_packages_sorted=$(echo "$orphan_packages" | awk '{ print $1 }' | sort -u)

start_spinner "Calculating how many orphan packages there are..."
for package in $orphan_packages_sorted;
do
	# Get the last line of of the corresponding package, hence the lastest version
	latest_pkg_line=$(echo "$orphan_packages" | grep -e "^$package " | tail -1)
	latest_version=$(echo "$latest_pkg_line" | awk '{ print $4; }')
	pkgs_to_update["$package"]="$latest_version"
done
stop_spinner

echo "Number of orphan packages needing an update : ${#pkgs_to_update[@]}"
yes_or_no "This can take a very long time, would you like to proceed ?" && echo "he said yes"
