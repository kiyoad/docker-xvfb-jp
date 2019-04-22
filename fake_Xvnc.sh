#!/bin/bash

display=${1#:}
argsize="${5}x24"
fixed=nonono

if [[ "${fixed^^}" = "NONONO" ]] ;then
    size=${argsize}
else
    size=1024x768x24
fi

cat <<EOF | sudo tee /etc/supervisor/conf.d/Xvfb_x11vnc.conf > /dev/null
[program:Xvfb]
command=/usr/bin/Xvfb ":${display}" -screen 0 "${size}" -nolisten tcp
priority=1
[program:x11vnc]
command=/usr/bin/x11vnc -display "WAIT:${display}" -reopen -shared -localhost -rfbport "$(( 5900 + display ))" -rfbportv6 -1 -repeat -nopw
priority=2
autorestart=true
EOF

trap 'sudo kill $(pgrep supervisord)' TERM INT
sudo supervisord -n -c /etc/supervisor/supervisord.conf &
pid=$!
wait "${pid}"
trap - TERM INT
wait "${pid}"
