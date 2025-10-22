FROM alpine:3

RUN apk update && apk upgrade && apk add --no-cache openrc mariadb mariadb-client mariadb-server-utils
COPY ./conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN /usr/bin/mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
RUN rc-update add mariadb
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
COPY tools/mariadb.sh /usr/local/bin/mariadb.sh
COPY tools/healtcheck.sh /tmp/healthcheck.sh
COPY conf/init.sql /etc/mysqld/init.sql
RUN chmod +x /usr/local/bin/mariadb.sh /tmp/healthcheck.sh
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
