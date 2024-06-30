#!/usr/bin/env bash
#
# Author: Clyhtsuriva


# FUNCTIONS
#
# printf_n_notify
# printf_accross_width
# local_update
# remote_update
# non_free_update
# pip_update
# update_scripts_repo
# update_whatis_db


# Print to stdout
# And as a notification
printf_n_notify(){

	printf "%s\n" "[$1]"
	notify-send "[$1]"

}


# Print a line across the entire width of the terminal
printf_accross_width(){

	printf "\n"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "$1"
	printf "\n"

}


# Update local xbps packages
# And clean the cache and remove orphans
local_update(){

	printf_n_notify "local update"

	$xi -u xbps && \
	$xi --sync --update --verbose && \
	$xr --clean-cache --remove-orphans --verbose

}


# Update remote debian server using Ansible
remote_update(){

	printf_n_notify "remote update"

	ansible-playbook --inventory-file "$HOME/workbench/ansible/hosts" \
		"$HOME/workbench/ansible/update_adjutor.yml"

}


# Update non-free xbps packages
non_free_update(){

	printf_n_notify "non-free update"

	pushd ~/workbench/auto-void-packages || exit 1
	./update-git-repo.sh
	cd ../void-packages || exit 1
	./xbps-src pkg discord && \
	$xi --repository=hostdir/binpkgs/nonfree discord
	./xbps-src pkg spotify && \
	$xi --repository=hostdir/binpkgs/nonfree spotify
	popd || exit 1

}


# Update pip packages needing one
pip_update(){

	printf_n_notify "pip update"

	"$HOME/workbench/pyvenv/bin/pip3" list --outdated --format=json | \
	jq -r '.[] | "\(.name)==\(.latest_version)"' | \
	xargs -n1 "$HOME/workbench/pyvenv/bin/pip3" install --upgrade

}


# Execute update-script-repo.sh
# to add, commit and push
# updates of my custom scripts
# and ansible playbooks
update_scripts_repo(){
	printf_n_notify "custom scripts repo update"

	update-scripts-repo.sh

}

update_whatis_db(){
	printf_n_notify "update whatis db"
	sudo makewhatis /usr/share/man
}


# MAIN

xi='sudo xbps-install'
xr='sudo xbps-remove'

printf_n_notify ">>> Global Update >>>"

local_update
printf_accross_width "%"
remote_update
printf_accross_width "%"
non_free_update
printf_accross_width "%"
pip_update
printf_accross_width "%"
update_scripts_repo
printf_accross_width "%"
update_whatis_db

printf_n_notify "<<< Global Update <<<"
