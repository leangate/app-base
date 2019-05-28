FROM ubuntu:bionic

RUN apt-get upgrade -y
RUN apt-get update && apt-get install -y gnupg2
RUN apt-get install -y wget curl git

# install xpra
RUN curl https://winswitch.org/gpg.asc | apt-key add - && \
    echo "deb http://winswitch.org/ bionic main" > /etc/apt/sources.list.d/xpra.list && \
    apt-get install -y software-properties-common x11-apps && \
    add-apt-repository universe && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y xpra xvfb xterm && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*

ADD infinityTerm.sh /usr/local/bin/infinityTerm
RUN chmod 777 /usr/local/bin/infinityTerm

# non-root user
RUN adduser --disabled-password --gecos "noname" --uid 1000 noname

# switch to user
USER noname

ENV DISPLAY=:100

VOLUME /data

WORKDIR /data

EXPOSE 10000

CMD xpra start --bind-tcp=0.0.0.0:10000 --html=on --start-child=infinityTerm --exit-with-children --daemon=no --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no
