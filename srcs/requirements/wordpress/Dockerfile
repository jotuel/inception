FROM alpine:3
RUN apk update && apk upgrade && apk add --no-cache php php-cgi fcgi php-fpm php-phar php-mysqli wget bash composer mariadb-client

RUN mkdir /opt/wordpress \
    && cd /opt/wordpress \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /opt/wordpress/wp-cli.phar \
    && mv /opt/wordpress/wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html && chown -R nobody:nobody /var/www/html
RUN mkdir -p /etc/php7/php-fpm.d
COPY conf/fpm.conf /etc/php83/php-fpm.d/zz-docker.conf
COPY tools/wp.sh /usr/local/bin/wordpress.sh
RUN chmod +x /usr/local/bin/wordpress.sh

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
