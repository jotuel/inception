FROM alpine:3
ENV PHP_MEMORY_LIMIT=1G
RUN apk update && apk upgrade && apk add php php-cgi fcgi php-fpm php-phar php-mysqli wget
RUN mkdir /opt/wordpress && cd /opt/wordpress && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /opt/wordpress/wp-cli.phar && mv /opt/wordpress/wp-cli.phar /usr/local/bin/wp
RUN mkdir -p /var/www/html
RUN /usr/bin/php -dmemory_limit=-1 /usr/local/bin/wp core download --allow-root --path=/var/www/html
RUN wp config create --dbname=db --dbuser=wordpress --prompt=dbpass  --dbpass=${WORDPRESS_DB_PASSWORD} --dbhost=localhost:3306 --skip-check --path=/var/www/html
COPY tools/wp.sh /tmp/wordpress.sh
RUN chmod +x /tmp/wordpress.sh

ENTRYPOINT ["/tmp/wordpress.sh"]
