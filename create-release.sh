#!/bin/bash
# Creates new package release in git.
# a skip-merge is about not merge master to release.

set -e
set -o pipefail

fail() {
    echo "Error: $*" 1>&2
    exit 1
}

current_branch=$(git rev-parse --abbrev-ref HEAD)

if [[ "$current_branch" != "release" ]]; then
    echo 'Checkout "release".'
    git checkout release
fi

if [[ "$1" == "skip-merge" ]]; then
    echo 'Skip merge master to release'
else
    git merge master
fi

if ! git diff --quiet; then
    fail 'Make sure you have no uncommitted changes in your repository.'
fi

echo "Current git commit is: $(git describe)"

read -p 'Enter new version (e.g. "1.8.0"): ' version
if [[ ! "$version" =~ ^[1-9][0-9]*\.[0-9]+\.[0-9]+$ ]]; then
    fail 'Unexpected version format.'
fi

read -p 'Enter new release number: ' release
if [[ ! "$release" =~ ^[1-9][0-9]*$ ]]; then
    fail 'Unexpected release format.'
fi

sed -i 's/\(^Version:\s*\).*/\1'"$version"'/' pdc-client.spec
sed -i 's/\(^Release:\s*\).*/\1'"$release"'%{?dist}/' pdc-client.spec

tito tag --keep-version

echo Do a test build here

tito build --test --srpm
