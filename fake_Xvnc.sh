#!/bin/bash
set -e
display=${1#:}
argsize="${5}x24"
fixed=nonono

if [[ "${fixed^^}" = "NONONO" ]] ;then
    size=${argsize}
else
    size=1024x768x24
fi

sudo sed -i -e "s/XXX/:${display}/" /usr/local/sbin/xrdp-chansrv
sudo Xvfb ":${display}" -screen 0 "${size}" -nolisten tcp &
sudo x11vnc -display ":${display}" -loop -reopen -shared -localhost -rfbport "$(( 5900 + display ))" -rfbportv6 -1 -repeat -nopw &
echo "${display}" > /var/tmp/fake_Xvnc_display
