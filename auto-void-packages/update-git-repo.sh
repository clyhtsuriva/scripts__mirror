#!/usr/bin/env bash

echo_n_notify(){
	echo "$1" && notify-send "$1"
}

pushd "$HOME/workbench/void-packages" || exit 1
CHECKOUT="checkout"
FETCH="fetch"
MERGE="merge"
PUSH="push"

git checkout master && \
	echo_n_notify "$CHECKOUT: ok" && \
	git fetch upstream && \
	echo_n_notify "$FETCH: ok" && \
	git merge upstream/master && \
	echo_n_notify "$MERGE: ok" && \
	git push && \
	echo_n_notify "$PUSH: ok"

./xbps-src bootstrap-update

popd || exit 1
