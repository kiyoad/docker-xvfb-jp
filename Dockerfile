FROM ubuntu:xenial

ARG INSTALL_USER=developer
ARG UID=1000

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y language-pack-ja tzdata sudo whois && \
rm -rf /var/lib/apt/lists/* && \
echo "lang en_US" > /etc/aspell.conf && \
update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata && \
useradd -u "${UID}" -p $(echo "${INSTALL_USER}" | mkpasswd -s -m sha-512) -m "${INSTALL_USER}" && \
chown -R "${INSTALL_USER}":"${INSTALL_USER}" "/home/${INSTALL_USER}" && \
echo "${INSTALL_USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${INSTALL_USER}" && \
chmod 0440 "/etc/sudoers.d/${INSTALL_USER}"

ENV LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" SHELL=/bin/bash TERM=xterm-256color

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y xvfb x11vnc xfce4 xfce4-goodies scim-anthy firefox fonts-ipafont vim && \
rm -rf /var/lib/apt/lists/* && \
mkdir /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix

RUN \
: version && xrdp=0.9.5 && xrdp_s=2 && xorgxrdp=0.2.5 && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y wget build-essential devscripts autoconf libtool pkg-config gcc g++ make libssl-dev libpam0g-dev libjpeg-dev libx11-dev libxfixes-dev libxrandr-dev flex bison libxml2-dev intltool xsltproc xutils-dev python-libxml2 xutils libfuse-dev libmp3lame-dev nasm libpixman-1-dev xserver-xorg-dev && \
rm -rf /var/lib/apt/lists/* && \
wget -q -O - "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xrdp/${xrdp}-${xrdp_s}/xrdp_${xrdp}.orig.tar.gz" | tar zxf - && \
mv xrdp-${xrdp} .build_xrdp && \
(cd .build_xrdp && ./bootstrap && ./configure --enable-fuse && make install) && \
rm -rf .build_xrdp && \
wget -q -O - "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xrdp/${xrdp}-${xrdp_s}/xrdp_${xrdp}.orig-xorgxrdp.tar.gz" | tar zxf - && \
mv xorgxrdp-${xorgxrdp} .build_xorgxrdp && \
(cd .build_xorgxrdp && ./bootstrap && ./configure && make install) && \
rm -rf .build_xorgxrdp

COPY startup.sh /usr/local/sbin/
COPY docker-xvfb-jp.xrdp.ini /etc/xrdp/xrdp.ini

USER ${INSTALL_USER}
WORKDIR /home/${INSTALL_USER}
ENTRYPOINT [ "/usr/local/sbin/startup.sh" ]
