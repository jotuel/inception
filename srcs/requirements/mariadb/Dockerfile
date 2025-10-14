FROM alpine:3

RUN apk update && apk upgrade && apk add openrc mariadb mariadb-client mariadb-server-utils
RUN /usr/bin/mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
RUN rc-update add mariadb default

COPY tools/mariadb.sh /tmp/mariadb.sh
RUN chmod +x /tmp/mariadb.sh

CMD ["/tmp/mariadb.sh"]
