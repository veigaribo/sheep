#!/usr/bin/env bash

last_commit=`git rev-parse HEAD`
last_tag=`git describe --tags --abbrev=0`

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# + v at the start. Non-capturing groups swapped for capturing ones because it should be more compatible I think.
tag_regex='^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-((0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

if ! echo -n "$last_tag" | grep -q -P "$tag_regex"; then
	echo "Tag '$last_tag' does not match the usual format of a SemVer string prefixed with 'v', like 'v1.2.3'. See <https://semver.org/>. Aborting." >&2
	exit 1
fi

echo $last_tag
echo $last_commit
