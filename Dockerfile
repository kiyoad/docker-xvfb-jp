FROM ubuntu:bionic AS build

# https://c-nergy.be/blog/?p=12469
RUN \
sed -i -e "s/^# deb-src/deb-src/" /etc/apt/sources.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -q -y xrdp-pulseaudio-installer && \
cd /tmp && apt source pulseaudio && \
cd /tmp/pulseaudio-11.1 && ./configure && \
cd /usr/src/xrdp-pulseaudio-installer && make PULSE_DIR="/tmp/pulseaudio-11.1" && \
install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so


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
DEBIAN_FRONTEND=noninteractive apt-get install -q -y supervisor xvfb x11vnc xrdp uim-anthy fonts-ipafont fonts-ricty-diminished ubuntu-mate-core && \
DEBIAN_FRONTEND=noninteractive apt-get remove -q -y blueman && \
DEBIAN_FRONTEND=noninteractive apt-get autoremove -q -y && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /tmp/.X11-unix && chmod a+rwxt /tmp/.X11-unix

COPY --from=build /var/lib/xrdp-pulseaudio-installer /var/lib/xrdp-pulseaudio-installer

COPY bootstrap.sh /usr/local/sbin/
COPY startup.sh /usr/local/sbin/
COPY fake_Xvnc.sh /usr/bin/X11/Xvnc
COPY docker-xvfb-jp.xrdp.ini /etc/xrdp/xrdp.ini
COPY docker-xvfb-jp.sesman.ini /etc/xrdp/sesman.ini

RUN mkdir /home/xvfb

ENTRYPOINT [ "/usr/local/sbin/bootstrap.sh" ]
