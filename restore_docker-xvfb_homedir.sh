#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RESTORE_FROM=/var/tmp
docker run --rm --volumes-from xvfb -v "${RESTORE_FROM}:/backup" busybox tar zxvf "/backup/xvfb_${LOGNAME}.tgz" -C /
