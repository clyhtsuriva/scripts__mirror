#!/usr/bin/env bash
#
# Clyhtsuriva
#
#
# -- potentia --
#
# Displays the battery percentage in the terminal
# and as a notification.
#

# An array containing the required programs
required_programs=("acpi" "notify-send")

# Check if each program is installed
for program in "${required_programs[@]}"; do
    if ! command -v "$program" &> /dev/null; then
        echo "Error: $program is not installed. Please install $program and try again."
        exit 1
    fi
done

# Get the current battery percentage using acpi
battery_level=$(acpi | awk '{print $4}' | tr -d ',')

# Display in the terminal
echo "Battery level: $battery_level"

# Send a notification using notify-send
notify-send "Battery level: $battery_level"
