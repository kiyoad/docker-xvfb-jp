FROM ubuntu:bionic

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y language-pack-ja tzdata sudo whois ssh && \
rm -rf /var/lib/apt/lists/* && \
update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y supervisor xvfb x11vnc xrdp uim-anthy fonts-ipafont ubuntu-mate-core && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y apt-transport-https gvfs-bin compizconfig-settings-manager && \
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y code git && \
rm -rf /var/lib/apt/lists/*

COPY bootstrap.sh /usr/local/sbin/
COPY startup.sh /usr/local/sbin/
COPY fake_Xvnc.sh /usr/bin/X11/Xvnc
COPY docker-xvfb-jp.xrdp.ini /etc/xrdp/xrdp.ini
COPY docker-xvfb-jp.sesman.ini /etc/xrdp/sesman.ini

ENTRYPOINT [ "/usr/local/sbin/bootstrap.sh" ]
