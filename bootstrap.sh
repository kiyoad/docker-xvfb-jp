#!/bin/bash
set -euo pipefail

logname=xvfb
password=${1}
uid=${2}
shift
shift

useradd -u "${uid}" -p $(echo "${password}" | mkpasswd -s -m sha-512) -s /bin/bash "${logname}"
chown "${uid}:${uid}" "/home/${logname}"
for f in $(cd /etc/skel; ls .[a-z]*);
do
    if [ ! -f "/home/${logname}/${f}" ]; then
        cp -p "/etc/skel/${f}" "/home/${logname}/${f}"
        chown "${uid}:${uid}"  "/home/${logname}/${f}"
    fi
done

echo "${logname} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${logname}"
chmod 0440 "/etc/sudoers.d/${logname}"

sed -i -e "s/@USERNAME/${logname}/" -e "s/@PASSWORD/${password}/" /etc/xrdp/xrdp.ini

sudo -i -u "${logname}" startup.sh "$@"
