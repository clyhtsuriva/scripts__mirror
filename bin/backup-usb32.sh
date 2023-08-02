#!/usr/bin/env bash

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <source_directory> <local_destination_directory> <remote_destination_directory> <username> <server_address> <ssh_port>"
    exit 1
fi

source_directory="$1"
local_destination_directory="$2"
remote_destination_directory="$3"
username="$4"
server_address="$5"
ssh_port="$6"

# Backup USB key to local machine
rsync -az -u -v "$source_directory" "$local_destination_directory"

# --archive, -a            archive mode is -rlptgoD (no -A,-X,-U,-N,-H)
# --compress, -z           compress file data during the transfer
# --update, -u             skip files that are newer on the receiver
# --verbose, -v            increase verbosity

# Backup USB key to server over SSH using the provided port
rsync -az -u -v -e "ssh -p $ssh_port" "$source_directory" "$username"@"$server_address":"$remote_destination_directory"
