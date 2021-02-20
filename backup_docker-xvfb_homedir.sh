#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

BACKUP_TO=/var/tmp
docker run --rm --volumes-from xvfb -v "${BACKUP_TO}:/backup" busybox tar zcvf "/backup/xvfb_${LOGNAME}.tgz" --exclude 'home/xvfb/.cache/*' /home/xvfb
