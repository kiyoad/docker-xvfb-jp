#!/bin/bash
export DISPLAY=XXX
exec /usr/local/sbin/orig_xrdp-chansrv > /tmp/xrdp-chansrv.log 2>&1
