#!/usr/bin/env bash

###
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)
###

usage () {
	printf "%s\t%s\n\n%s\n %s\t%s\n %s\t%s\n" \
	"Usage:" "$(basename "$0") [options] [filename]" \
	"Basic options:" \
	"-h" "show this help page" \
	"-d" "dESTROY the waste bin's content"
	exit "$1"
}

[ ${#} -eq 1 ] || usage 1
WASTE="$1"
[ -f "$WASTE" ] || [ -d "$WASTE" ] || usage 1

WASTE_BIN="$HOME/.local/waste_bin"
[ -d "$WASTE_BIN" ] || \
	( mkdir "$WASTE_BIN" && \
	printf "%s[Creating the following directory : %s]%s\n" "$MAGENTA" "$WASTE_BIN" "$NORMAL" )

printf "%s[Moving %s to the waste bin]%s\n" "$CYAN" "$1" "$NORMAL"
mv --verbose --target-directory="$WASTE_BIN" "$1" || \
	printf "%s[An error occured while moving %s to %s]%s\n" "$RED" "$1" "$WASTE_BIN" "$NORMAL"
