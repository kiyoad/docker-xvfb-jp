#!/bin/bash
set -euo pipefail

function cleanup (){
    set +e
    sudo kill $(sudo ps -e | grep xrdp | awk '{print $1}')
    sudo kill $(sudo ps -e | grep x11vnc | awk '{print $1}')
    sudo kill $(sudo ps -e | grep Xvfb | awk '{print $1}')
    sleep 1
    sudo rm -f "/tmp/.X11-unix/X${display}"
    exit 0
}
trap cleanup 1 2 3 15

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
    sudo Xvfb ":${display}" -screen 0 "${size}" -nolisten tcp &
    sudo x11vnc -display ":${display}" -loop -reopen -shared -localhost -rfbport "${vncport}" -rfbportv6 -1 -repeat -nopw &
    sleep 2
    DISPLAY=":${display}" startxfce4 &
    child=$!
    wait ${child}
else
    sudo xrdp
    set +e
    sudo xrdp-sesman -n
    set -e
fi
cleanup
