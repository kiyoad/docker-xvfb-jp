FROM ubuntu:xenial

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y language-pack-ja tzdata sudo whois && \
rm -rf /var/lib/apt/lists/* && \
update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y xvfb x11vnc xfce4 xfce4-goodies scim-anthy fonts-ipafont && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix

RUN \
: version && xrdp=0.9.5 && xrdp_s=2 && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y wget autoconf libtool pkg-config gcc g++ make libssl-dev libpam0g-dev libjpeg-dev libx11-dev libxfixes-dev libxrandr-dev flex bison libxml2-dev intltool xsltproc xutils-dev python-libxml2 xutils libfuse-dev libmp3lame-dev nasm libpixman-1-dev xserver-xorg-dev && \
rm -rf /var/lib/apt/lists/* && \
wget -q -O - "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xrdp/${xrdp}-${xrdp_s}/xrdp_${xrdp}.orig.tar.gz" | tar zxf - && \
mv xrdp-${xrdp} .build_xrdp && \
(cd .build_xrdp && ./bootstrap && ./configure && make install) && \
mv /usr/local/sbin/xrdp-chansrv /usr/local/sbin/orig_xrdp-chansrv && \
rm -rf .build_xrdp

COPY bootstrap.sh /usr/local/sbin/
COPY startup.sh /usr/local/sbin/
COPY fake_Xvnc.sh /usr/bin/X11/Xvnc
COPY fake_xrdp-chansrv.sh /usr/local/sbin/xrdp-chansrv
COPY docker-xvfb-jp.xrdp.ini /etc/xrdp/xrdp.ini

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y firefox vim less && \
rm -rf /var/lib/apt/lists/*

RUN \
  : version && node=8.11.2 && \
  wget -q -O - https://nodejs.org/dist/v${node}/node-v${node}-linux-x64.tar.xz | tar -C /usr/local -xJf - && \
  chown -R root:root /usr/local/node-v${node}-linux-x64 && \
  export PATH=/usr/local/node-v${node}-linux-x64/bin:${PATH} && \
  npm install -g --production eslint && \
  (cd /usr/local/node-v${node}-linux-x64 && find bin -xtype f -exec ln -s /usr/local/node-v${node}-linux-x64/{} /usr/local/{} \;)

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl apt-transport-https gvfs-bin compizconfig-settings-manager && \
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y code git && \
rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/usr/local/sbin/bootstrap.sh" ]
