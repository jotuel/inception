FROM alpine:3

RUN apk update && apk upgrade && apk add --no-cache openrc mariadb mariadb-client mariadb-server-utils gettext

COPY ./conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY conf/init.sql /etc/mysql/init.sql

RUN /usr/bin/mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --skip-test-db
RUN rc-update add mariadb

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

COPY tools/mariadb.sh /usr/local/bin/mariadb.sh
COPY tools/healtcheck.sh /tmp/healthcheck.sh

RUN chmod +x /usr/local/bin/mariadb.sh /tmp/healthcheck.sh

#EXPOSE 3306

ENTRYPOINT ["mariadbd", "--console"]
