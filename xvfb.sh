#!/bin/bash
set -euo pipefail
docker run --rm -d -v /tmp/.X11-unix:/tmp/.X11-unix -v "${HOME}:/home/${LOGNAME}" --name xvfb kiyoad/xvfb "${LOGNAME}" "${LOGNAME}" "$(id -u)" "$@"
