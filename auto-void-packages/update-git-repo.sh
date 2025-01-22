#!/usr/bin/env bash

echo_n_notify(){
	echo "$1" && notify-send "$1"
}

pushd "$HOME/workbench/void-packages" || exit 1

git checkout master && \
	echo_n_notify "checkout: ok" && \
	git fetch upstream && \
	echo_n_notify "fetch: ok" && \
	git merge upstream/master && \
	echo_n_notify "merge: ok" && \
	git push && \
	echo_n_notify "push: ok"

./xbps-src bootstrap-update

popd || exit 1
