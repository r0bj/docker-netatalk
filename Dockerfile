FROM debian:jessie

ENV NETATALK_VERSION 3.1.12

ENV BUILD_DEPS  \
                build-essential \
                libevent-dev \
                libssl-dev \
                libgcrypt11-dev \
                libkrb5-dev \
                libpam0g-dev \
                libwrap0-dev \
                libdb-dev \
                libtdb-dev \
                libmysqlclient-dev \
                libavahi-client-dev \
                libacl1-dev \
                libldap2-dev \
                libcrack2-dev \
                systemtap-sdt-dev \
                libdbus-1-dev \
                libdbus-glib-1-dev \
                libglib2.0-dev \
                libtracker-sparql-1.0-dev \
                libtracker-miner-1.0-dev \
                file

ENV PERSISTENT_RUNTIME_DEPS \
                libevent-2.0 \
                libavahi-client3 \
                libevent-core-2.0 \
                libwrap0 \
                libtdb1 \
                libmysqlclient18 \
                libcrack2 \
                libdbus-glib-1-2 


ENV DEBIAN_FRONTEND=noninteractive

RUN     apt-get update \
        && apt-get install \
                --no-install-recommends \
                --fix-missing \
                --assume-yes \
                $BUILD_DEPS \
                tracker \
                avahi-daemon \
                curl \
                wget \
        \
        && curl -sSL  http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz -O \
        && tar fxvz netatalk-${NETATALK_VERSION}.tar.gz \
        && cd netatalk-${NETATALK_VERSION} \
        \
        && ./configure \
                --prefix=/usr \
                --sysconfdir=/etc \
                --with-init-style=debian-systemd \
                --without-libevent \
                --without-tdb \
                --with-cracklib \
                --enable-krbV-uam \
                --with-pam-confdir=/etc/pam.d \
                --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
                --with-tracker-pkgconfig-version=1.0 \
        &&  make -j "$(nproc)" \
        &&  make install \
        \
        &&  apt-get --quiet --yes purge --auto-remove \
                $BUILD_DEPS \
                tracker-gui \
                libgl1-mesa-dri \
        \
        &&  apt-get install --yes $PERSISTENT_RUNTIME_DEPS \
        \
        &&  apt-get --quiet --yes autoclean \
        &&  apt-get --quiet --yes autoremove \
        &&  apt-get --quiet --yes clean \
        &&  cd / \
        &&  rm -rf netatalk-${NETATALK_VERSION} \
        &&  rm -rf /usr/share/man \
        &&  rm -rf /usr/share/doc \
        &&  rm -rf /usr/share/icons \
        &&  rm -rf /usr/share/poppler \
        &&  rm -rf /usr/share/mime \
        &&  rm -rf /usr/share/GeoIP \
        &&  rm -rf /var/lib/apt/lists* \
        &&  mkdir -p /media/share

RUN wget -qO /usr/bin/confd --no-check-certificate https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && chmod +x /usr/bin/confd
COPY confd /etc/confd

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
