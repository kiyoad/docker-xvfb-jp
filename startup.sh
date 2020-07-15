#!/bin/bash
set -uo pipefail

if [[ $# -ge 1 ]] ;then
    size="${1}x24"
    sudo sed -i -e "s/1024x768x24/${size}/" -e "s/NONONO/YESYES/" /usr/bin/X11/Xvnc
fi

if [[ $# -ge 2 ]] ;then
    vncport="${2}"
    if [[ $# -ge 3 ]] ;then
        display="${3}"
    else
        display=10
    fi

    sudo rm -f "/tmp/.X11-unix/X${display}"
    cat <<EOF | sudo tee /etc/supervisor/conf.d/Xvfb_x11vnc.conf > /dev/null
[program:Xvfb]
command=/usr/bin/Xvfb ":${display}" -screen 0 "${size}" -nolisten tcp
priority=1
[program:x11vnc]
command=/usr/bin/x11vnc -display "WAIT:${display}" -reopen -shared -rfbport "${vncport}" -rfbportv6 -1 -repeat -nopw -noxrecord
priority=2
autorestart=true
EOF

    export DISPLAY=":${display}"
    sudo supervisord -c /etc/supervisor/supervisord.conf
    while :
    do
        sleep 2
        /etc/xrdp/startwm.sh
        kill $(ps --no-header -u "${USER}" | grep -v "$(basename $0)" | awk '{print $1;}') > /dev/null 2>&1
        sudo kill -HUP $(pgrep supervisord)
    done
else
    sudo rm -f "/tmp/.X11-unix/X10"
    sudo xrdp
    exec sudo xrdp-sesman -n
fi
