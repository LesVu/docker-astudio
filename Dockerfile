FROM debian:bookworm as temp
COPY android-studio-*-cros.deb android-studio.deb
RUN mkdir /temp && dpkg-deb -x android-studio.deb /temp && rm android-studio.deb

FROM debian:sid
ARG user=char

LABEL maintainer="LesVu"

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

RUN dpkg --add-architecture armhf && echo 'deb http://deb.debian.org/debian sid contrib' > /etc/apt/sources.list && apt-get update \
  && apt-get full-upgrade -y -q \
  && apt-get install libc6:armhf -y -q \
  && apt-get install -q -y --no-install-recommends \
  gnupg lsb-release curl tar unzip zip \
  apt-transport-https ca-certificates sudo gpg-agent software-properties-common zlib1g-dev \
  zstd gettext libcurl4-openssl-dev inetutils-ping jq wget dirmngr openssh-client locales \
  && apt-get install -q -y git cmake binfmt-support wayvnc wayfire xwayland kanshi xterm vim zenity pulseaudio bemenu default-jdk \
  && apt-get install -y -q libc6:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf libncurses6:armhf libgl1-mesa-dri:armhf libibus-1.0-5 libibus-1.0-5:armhf \
  && apt-get clean && rm -rf /var/lib/apt/lists/* 

COPY --from=temp /temp/* /

RUN wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list && wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
  && wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg \
  && apt-get update && apt-get install -q -y box86:armhf box64 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY files/binfmts/* /usr/share/binfmts
RUN update-binfmts --import

RUN useradd -m -s /bin/bash -G sudo,video,audio ${user} && echo "${user}:${user}" | chpasswd && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY files/start.sh /start.sh
COPY files/wayfire.ini /home/${user}/.config/wayfire.ini

RUN sed -i "s/# \(en_US\.UTF-8 .*\)/\1/" /etc/locale.gen && sed -i "s/# \(ja_JP\.UTF-8 .*\)/\1/" /etc/locale.gen && locale-gen

RUN echo "load-module module-native-protocol-tcp auth-anonymous=1" >> /etc/pulse/default.pa && chown -R ${user}:${user} /home/${user}

# wget -q https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-aarch64.deb -O rustdesk.deb && sudo apt-get install -f -y -q ./rustdesk.deb && rm rustdesk.deb

USER ${user}
WORKDIR /home/${user}
CMD [ "/start.sh" ]
EXPOSE 5900
