#!/bin/bash

set -eo pipefail

if [ "$1" != "fpm-cook" ]; then
	exec "$@"
fi

# Signal fpm-cook that we are already running inside a container to avoid
# trying to start another one.
export FPMC_INSIDE_DOCKER=true

if [ -x "/usr/bin/apt-get" ]; then
	# Ubuntu/Debian containers use a custom apt config to remove archives
	# after installing a package. We don't want that because it removes
	# the possibility to cache the apt archive directory.
	rm -f /etc/apt/apt.conf.d/docker-clean

	# Make sure we have updated apt repositories. Container images usually
	# have either no updated lists or they are outdated.
	if [ -n "$FPMC_DEBUG" ]; then
		apt-get update
	else
		apt-get update >/dev/null
	fi
fi

# Remove existing temporary directories to ensure a full build
rm -rf tmp-build tmp-dest

shift
fpm-cook "$@"

if [ -n "$FPMC_UID" -a -n "$FPMC_GID" ]; then
	# Change ownership to make sure the user that executed fpm-cook can
	# modify created files.
	chown -R ${FPMC_UID}:${FPMC_GID} cache pkg tmp-build tmp-dest
fi
