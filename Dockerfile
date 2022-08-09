FROM ubuntu:20.04

LABEL maintainer="Abolfazl Sharifi <abolfazl.dev@gmail.com>"


ENV DEBIAN_FRONTEND noninteractive

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update

RUN apt-get install -y gnupg software-properties-common \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C

RUN apt-get install -y curl nano wget ca-certificates zip unzip git supervisor cron rsyslog libcap2-bin libpng-dev python2 python certbot \
    make cmake gcc g++ libmad0-dev libid3tag0-dev libsndfile1-dev libgd-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev

RUN add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php8.1-cli php8.1-fpm php8.1-dev \
    php8.1-pgsql php8.1-sqlite3 php8.1-gd \
    php8.1-curl \
    php8.1-imap php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
    php8.1-intl php8.1-readline \
    php8.1-ldap \
    php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-mongodb php8.1-swoole \
    php8.1-memcached php8.1-pcov php8.1-xdebug 

RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN apt-get install -y ffmpeg

RUN cd /tmp \
    && git clone https://github.com/bbc/audiowaveform.git \
    && cd audiowaveform \
    && git clone --depth=1 https://github.com/google/googletest.git -b release-1.11.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install' 

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get -y autoremove \
    && apt-get clean


ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupadd --force -g ${PGID} workspace
RUN useradd -ms /bin/bash --no-user-group -g ${PGID} -u ${PUID} workspace


COPY entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 9000

ENTRYPOINT ["entrypoint"]
