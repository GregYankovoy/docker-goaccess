FROM gregyankovoy/alpine-base

ARG build_deps="build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev"
ARG runtime_deps="nginx tini ncurses libintl libmaxminddb"
ARG geolite_city_link="to be replaced by build agent"
ARG geolite_version="to be replaced by build agent"

WORKDIR /goaccess

# Build goaccess with mmdb geoip
RUN wget -q -O - https://github.com/allinurl/goaccess/archive/v1.4.tar.gz | tar --strip 1 -xzf - && \
    apk add --update --no-cache ${build_deps} && \
    autoreconf -fiv && \
    ./configure --enable-utf8 --enable-geoip=mmdb && \
    make && \
    make install && \
    rm -rf /tmp/goaccess/* /goaccess && \
    apk del $build_deps

# Get necessary runtime dependencies and set up configuration
RUN apk add --update --no-cache ${runtime_deps} && \
    mkdir -p /usr/local/share/GeoIP && \
    wget -q -O- ${geolite_city_link} | tar -xz --strip 1 --directory /usr/local/share/GeoIP

COPY /root /

RUN chmod +x /usr/local/bin/goaccess.sh && \
    chmod -R 777 /var/tmp/nginx

EXPOSE 7889
VOLUME [ "/config", "/opt/log", "/opt/data" ]

CMD [ "sh", "/usr/local/bin/goaccess.sh" ]
