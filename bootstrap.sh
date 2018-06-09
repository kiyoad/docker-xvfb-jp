#!/bin/bash
set -euo pipefail

logname=${1}
password=${2}
uid=${3}
shift
shift
shift

useradd -u "${uid}" -p $(echo "${password}" | mkpasswd -s -m sha-512) -s /bin/bash "${logname}"
echo "${logname} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${logname}"
chmod 0440 "/etc/sudoers.d/${logname}"

sed -i -e "s/@USERNAME/${logname}/" -e "s/@PASSWORD/${password}/" /etc/xrdp/xrdp.ini

sudo -i -u "${logname}" startup.sh "$@"
