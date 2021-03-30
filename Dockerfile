FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:buster
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends gimp && \
    rm -rf /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY src/menu.xml /etc/xdg/openbox/
COPY src/rc.xml /etc/xdg/openbox/
COPY src/supervisord.conf /etc/
EXPOSE 8080

ENV USERID=1000
ENV GROUPID=1000

RUN groupadd --gid ${GROUPID} app && \
    useradd --home-dir /data --shell /bin/bash --uid ${USERID} --gid ${GROUPID} app && \
    mkdir -p /data
VOLUME /data

CMD ["sh", "-c", "exec gosu app supervisord > /dev/null"]


