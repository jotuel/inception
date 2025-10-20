FROM alpine:3

RUN apk update && apk upgrade && apk add openrc mariadb mariadb-client mariadb-server-utils
RUN adduser mysql || true && adduser -D -G mysql -h /run/mysql/ -s /bin/sh mysql || true
RUN mkdir -p /run/mysql && chown mysql:mysql /run/mysql/ && chmod 755 /run/mysql
COPY ./conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN /usr/bin/mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
COPY tools/mariadb.sh /tmp/mariadb.sh
COPY tools/healtcheck.sh /tmp/healthcheck.sh
RUN chmod +x /tmp/mariadb.sh /tmp/healthcheck.sh
EXPOSE 3306
ENTRYPOINT ["/tmp/mariadb.sh"]
