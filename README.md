# docker-xvfb-jp

The Docker container which can connect to X window system (Xvfb) with
RDP client or VNC client in SSH port forwarding environment.

This container runs on the remote server and connects from the local
PC with RDP client or VNC client. However, in advance SSH login with
port forwarding must be done from the local PC to the remote
server. Therefore, logging out of SSH from a remote server causes the
RDP (VNC) client to be disconnected. Remote server and RDP (VNC)
client can not connect directly.

## Getting Started
### Prerequisites

What things you need to install the software.

* Connectivity to the INTERNET for `docker build`
* Docker on Linux

```
$ docker version
Client:
 Version:           18.09.0
 API version:       1.39
 Go version:        go1.10.4
 Git commit:        4d60db4
 Built:             Wed Nov  7 00:48:57 2018
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.4
  Git commit:       4d60db4
  Built:            Wed Nov  7 00:16:44 2018
  OS/Arch:          linux/amd64
  Experimental:     false
```

* a SSH client on your local PC.(also use the port forwarding function)
    * Tera Term

* a RDP client or a VNC client on your local PC.
    * Microsoft Remote Desktop
    * RealVNC VNC Viewer


### Installing

1. Localize the Dockerfile as necessary.(Default: Japanese)
    * The following are localized parts.

    ```
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -q -y language-pack-ja tzdata sudo whois && \
    rm -rf /var/lib/apt/lists/* && \
    update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
    cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

    ENV LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

    RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y xvfb x11vnc xfce4 xfce4-goodies scim-anthy fonts-ipafont && \
    ```
    * Check `language-pack-??`, `LANG`, `LANGUAGE`, `zoneinfo`, input methods(ja:scim-anthy) and `fonts-???`

1. Run `docker_build.sh` and wait a while.
    * `$ ./docker_build.sh`

## Running

1. Make SSH connection with port forwarding from the local PC to the remote server.
    * Local PC:127.0.0.1:13389 -> Remote server:127.0.0.1:3389 for RDP client.
    * Local PC:127.0.0.1:5900 -> Remote server:127.0.0.1:5900 for VNC client.

1. Use `xvfb.sh` with some/no arguments. Perform one of the following:
    1. `$ ./xvfb.sh` with NO arguments is RDP connection mode.
        * When there is no argument at startup, it becomes the screen size specified by RDP client.
    1. `$ ./xvfb.sh 1024x768` is RDP connection mode.
        * Specify the screen size with WxH. Ignore the size specified by the RDP client.
    1. `$ ./xvfb.sh 1024x768 5900` is VNC connection mode.
        * Specify the screen size and VNC connection port number.
        * It is not possible to specify only the VNC connection port number.
        * The VNC connection port number must be equal to the port number on the remote server side in SSH port forwarding.
    1. `$ ./xvfb.sh 1024x768 5900 10` is VNC connection mode.
        * Specify the screen size, VNC connection port number and X display number.
        * If X display number is not specified, use 10.

1. Connect with client according to each connection mode.
    * In RDP connection mode.
        1. Connect to 127.0.0.1:13389 with the RDP client on the local PC.
        1. Check the security dialog and select 'YES'.
        1. Confirm that the session dialog of xrdp is 'Direct' and select 'YES'.
        1. Successful when Xfce's desktop is displayed.
    * In VNC connection mode.
        1. Connect to 127.0.0.1:5900 with the VNC client on the local PC.
        1. Successful when Xfce's desktop is displayed.

1. Choosing 'Logout' from the Xfce desktop application menu will terminate your RDP/VNC client connetion. But the container does not stop. Container should be stopped with `docker stop xvfb`.


## Note

* Multiple instances of this container(`xvfb.sh`) can not be started simultaneously.
* By specifying the X display number, you can use the X client outside the container on the same remote server.
    * A valid X display number can be found by the following command.
        * `$ sudo ls /tmp/.X11-unix/`
        * The remainder of the result excluding the leading character 'X' becomes the X display number.
* The user name in Xfce is `xvfb`, and the password default is the environment variable LOGNAME at the time of execution the container. Please check `xvfb.sh`.
* The home directory when running Xfce is `/home/xvfb`. Your home directory also mounts at `/home/${LOGNAME}`


## Bug

* No sound supported.


## License

This project is licensed under the MIT License.
