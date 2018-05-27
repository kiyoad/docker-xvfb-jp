#!/bin/bash
set -euo pipefail
if [[ $# -eq 0 ]]; then
  size=1024x768
else
  size=${1}
fi
sudo Xvfb :0 -screen 0 "${size}x24" -nolisten tcp &
sleep 2
sudo x11vnc -display :0 -loop -reopen -shared -localhost -rfbport 5900 -rfbportv6 -1 -repeat -nopw &
export DISPLAY=:0
sudo xrdp
startxfce4
