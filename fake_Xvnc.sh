#!/bin/bash

display=${1#:}
argsize="${5}x24"
fixed=nonono

if [[ "${fixed^^}" = "NONONO" ]] ;then
    size=${argsize}
else
    size=1024x768x24
fi

sudo sed -i -e "s/XXX/:${display}/" /usr/local/sbin/xrdp-chansrv

stopper(){
    echo "${pid1} ${pid2}" > /var/tmp/pidpid
    sudo kill -TERM "$(pgrep Xvfb)" "$(pgrep x11vnc)"
    sleep 1
    while ps "${pid1}" "${pid2}" > /dev/null 2>&1
    do
        sudo kill -TERM "$(pgrep Xvfb)" "$(pgrep x11vnc)"
        sleep 1
    done
    sudo rm -f "/tmp/.X11-unix/X${display}"
}

trap stopper TERM INT
sudo Xvfb ":${display}" -screen 0 "${size}" -nolisten tcp &
pid1=$!
sudo x11vnc -display ":${display}" -shared -localhost -rfbport "$(( 5900 + display ))" -rfbportv6 -1 -repeat -nopw &
pid2=$!
wait "${pid1}" "${pid2}"
trap - TERM INT
wait "${pid1}" "${pid2}"
