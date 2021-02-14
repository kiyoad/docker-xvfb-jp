FROM ubuntu:focal AS build

# https://c-nergy.be/blog/?p=13655
RUN \
sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y pulseaudio git libpulse-dev autoconf m4 intltool build-essential dpkg-dev && \
DEBIAN_FRONTEND=noninteractive apt build-dep -q -y pulseaudio && \
cd /root && apt source pulseaudio && \
pulseaudio=$(pulseaudio --version | awk '{print $2}') && \
cd /root/pulseaudio-${pulseaudio} && ./configure && \
cd /root && git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && \
cd /root/pulseaudio-module-xrdp && ./bootstrap && ./configure PULSE_DIR="/root/pulseaudio-${pulseaudio}" && make && \
cd /root/pulseaudio-module-xrdp/src/.libs && \
install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so


FROM ubuntu:focal

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y language-pack-ja tzdata sudo whois ssh apt-utils && \
rm -rf /var/lib/apt/lists/* && \
update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

ENV LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y supervisor xvfb x11vnc xrdp uim-anthy fonts-ipafont fonts-ricty-diminished vim less ubuntu-desktop && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix

COPY --from=build /var/lib/xrdp-pulseaudio-installer /var/lib/xrdp-pulseaudio-installer

COPY bootstrap.sh /usr/local/sbin/
COPY startup.sh /usr/local/sbin/
COPY fake_Xvnc.sh /usr/bin/X11/Xvnc
COPY docker-xvfb-jp.xrdp.ini /etc/xrdp/xrdp.ini
COPY docker-xvfb-jp.sesman.ini /etc/xrdp/sesman.ini
COPY 98pulseaudio /etc/X11/Xsession.d/

RUN mkdir /home/xvfb

ENTRYPOINT [ "/usr/local/sbin/bootstrap.sh" ]
