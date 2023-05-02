#!/usr/bin/env bash

### Define terminal color variables ###
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)
###

# Define the usage function that prints out how to use the script
usage () {
	# Print out the usage with formatting
	printf "%s\t%s\n\n%s\n %s\t%s\n %s\t%s\n" \
	"Usage:" "$(basename "$0") [options] [filename]" \
	"Basic options:" \
	"-h" "show this help page" \
	"-d" "dESTROY the waste bin's content"
	# Exit with the given error code
	exit "$1"
}

# Ensure there is only one argument or show usage and exit with error code 1
[ ${#} -eq 1 ] || usage 1

# Set the variable for the filename/directory to be moved to the waste bin
WASTE="$1"
# Ensure the file/directory exists or show usage and exit with error code 1
[ -f "$WASTE" ] || [ -d "$WASTE" ] || usage 1

# Set the path to the waste bin directory
WASTE_BIN="$HOME/.local/waste_bin"
# If the waste bin directory doesn't exist, create it and print a message
[ -d "$WASTE_BIN" ] || \
	( mkdir "$WASTE_BIN" && \
	printf "%s[Creating the following directory : %s]%s\n" "$MAGENTA" "$WASTE_BIN" "$NORMAL" )

# Print a message stating the file/directory is being moved to the waste bin
printf "%s[Moving %s to the waste bin]%s\n" "$CYAN" "$1" "$NORMAL"
# Move the file/directory to the waste bin or print an error message if it fails
mv --verbose --target-directory="$WASTE_BIN" "$1" || \
	printf "%s[An error occurred while moving %s to %s]%s\n" "$RED" "$1" "$WASTE_BIN" "$NORMAL"
