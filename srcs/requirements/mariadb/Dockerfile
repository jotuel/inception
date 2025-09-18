FROM alpine:3

RUN apk update && apk upgrade && apk add openrc mariadb mariadb-client mariadb-server-utils
RUN /usr/bin/mariadb-install-db --user=mysql --datadir=/var/lib/mysql
RUN rc-update add mariadb default

CMD ["mysqld_safe"]
