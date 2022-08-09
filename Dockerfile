FROM ubuntu:20.04

LABEL maintainer="Abolfazl Sharifi <abolfazl.dev@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y gnupg software-properties-common \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && apt-get install -y curl nano wget ca-certificates zip unzip git supervisor cron rsyslog libcap2-bin libpng-dev python2 python certbot \
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
    php8.1-memcached php8.1-pcov php8.1-xdebug \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get install -y ffmpeg \
    && cd /tmp \
    && git clone https://github.com/bbc/audiowaveform.git \
    && cd audiowaveform \
    && git clone --depth=1 https://github.com/google/googletest.git -b release-1.11.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

ARG PUID=1000
ARG PGID=1000

RUN groupadd --force -g ${PGID} workspace \
    && useradd -ms /bin/bash --no-user-group -g ${PGID} -u ${PUID} workspace

COPY entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 9000

ENTRYPOINT ["entrypoint"]
