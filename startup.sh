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
command=/usr/bin/x11vnc -display ":${display}" -reopen -shared -rfbport "${vncport}" -rfbportv6 -1 -repeat -nopw
priority=2
EOF

    export DISPLAY=":${display}"
    sudo supervisord -c /etc/supervisor/supervisord.conf
    sleep 2
    while :
    do
        startxfce4
    done
else
    sudo rm -f "/tmp/.X11-unix/X10"
    sudo xrdp
    exec sudo xrdp-sesman -n
fi
