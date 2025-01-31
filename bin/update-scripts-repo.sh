#!/usr/bin/env bash
# Author : Clyhtsuriva

SCRIPTS_REPO_PATH="$HOME/workbench/scripts/"

pushd "$SCRIPTS_REPO_PATH" || exit 1

cp -rv "$HOME/.local/usr/local/bin" .
cp -rv "$HOME/workbench/auto-void-packages" .

git status | less
git add --patch . && git commit -v && git push -v --progress

popd || exit 1
