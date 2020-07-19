#!/bin/bash
set -euo pipefail
PASSWORD="${LOGNAME}"
docker run --rm -d -v /dev/shm:/dev/shm -v /tmp/.X11-unix:/tmp/.X11-unix -v "xvfb_${LOGNAME}:/home/xvfb" -v "${HOME}:/home/${LOGNAME}" --net="host" --hostname xvfb --name xvfb kiyoad/xvfb "${PASSWORD}" "$(id -u)" "$@"
