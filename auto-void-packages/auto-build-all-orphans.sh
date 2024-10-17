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

typeset -i spinner_pid

typeset void_updates_url=""
typeset void_updates_content=""
typeset orphan_packages=""
typeset orphan_packages_sorted=""
typeset package=""

typeset -A pkgs_to_update=()

typeset -i nb_of_pkgs_to_build=0
typeset pkgs_to_exclude=""
typeset auto_build_archs_path=""
typeset -i pkg_counter=0

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

### FUNCTIONS

function helpy {
	printf "command: %s [number_of_packages] [pkgs_to_exclude]\n" "$0"
printf "number_of_packages: Must be an integer, indicates of many packages you want to auto build, defaults to none.\n"
printf "pkgs_to_exclude: Must be one or a list of packages name separated by commas, e.g., ansible,xonsh,ampache"
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

### MAIN ###

void_updates_url="https://repo-fi.voidlinux.org/void-updates/void-updates.txt"
void_updates_content=$(curl --silent "$void_updates_url")
orphan_packages=$(echo "$void_updates_content" | sed -n '/orphan@voidlinux.org/,/@/p' | grep -v '^--' | grep -v '@')
orphan_packages_sorted=$(echo "$orphan_packages" | awk '{ print $1 }' | sort -u)

nb_of_pkgs_to_build="${1:-0}"
pkgs_to_exclude=${2:-}

start_spinner "Calculating how many orphan packages there are..."
for package in $orphan_packages_sorted;
do
	# Get the last line of of the corresponding package, hence the lastest version
	latest_pkg_line=$(echo "$orphan_packages" | grep -e "^$package " | tail -1)
	latest_version=$(echo "$latest_pkg_line" | awk '{ print $4; }')
	pkgs_to_update["$package"]="$latest_version"
done
stop_spinner

echo -n "Number of orphan packages needing an update : " ; printf_green "${#pkgs_to_update[@]}"
echo -n "Number of orphan packages you want to build : " ; printf_red "$nb_of_pkgs_to_build"
echo -n "Packages you want to exclude : " ; printf_red "$pkgs_to_exclude"

[ $nb_of_pkgs_to_build == 0 ] && exit 1

echo "Executing update-git-repo.sh"
./update-git-repo.sh || exit 1

for package in "${!pkgs_to_update[@]}"; do

	echo "DEBUG : package : $package"

	# If the currently selected package is in the exclude list, continue to the next package
	if echo "$pkgs_to_exclude" | grep -q "$package"; then #TODO
		echo "DEBUG : before continue"
		continue
		echo "DEBUG : after continue"
	fi
	echo "DEBUG : after if exclude"

	# If we've hit the max number of packages asked by the user, break the loop
	if [ $pkg_counter -ge $nb_of_pkgs_to_build ]; then
		break
	fi

	latest_version="${pkgs_to_update[$package]}"
	auto_build_archs_path="$HOME/workbench/auto-void-packages/auto-build/archs-${package}-${latest_version}.txt"
	echo "[$package - $latest_version]"

	./update-package.sh "$package" "$latest_version" "$auto_build_archs_path"

	((pkg_counter++))
done
