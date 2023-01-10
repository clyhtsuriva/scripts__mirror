#!/usr/bin/env bash

rsync -az -u -v /mnt/32 ~/Documents/32.bak/

# --archive, -a            archive mode is -rlptgoD (no -A,-X,-U,-N,-H)
# --compress, -z           compress file data during the transfer
# --update, -u             skip files that are newer on the receiver
# --verbose, -v            increase verbosity
