#!/bin/bash
set -euo pipefail
PASSWORD="${LOGNAME}"
docker run --init --rm -d --privileged -v /var/run/dbus:/var/run/dbus -v /dev/shm:/dev/shm -v /tmp/.X11-unix:/tmp/.X11-unix -v "xvfb_${LOGNAME}:/home/xvfb" -v "${HOME}:/home/${LOGNAME}" --hostname xvfb --name xvfb kiyoad/xvfb "${PASSWORD}" "$(id -u)" "$@"
