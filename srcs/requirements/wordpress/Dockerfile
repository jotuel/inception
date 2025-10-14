FROM alpine:3
ENV PHP_MEMORY_LIMIT=1G
RUN apk update && apk upgrade && apk add php php-cgi fcgi php-fpm php-phar php-mysqli wget
RUN mkdir /opt/wordpress && cd /opt/wordpress && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /opt/wordpress/wp-cli.phar && mv /opt/wordpress/wp-cli.phar /usr/local/bin/wp
RUN /usr/bin/php -dmemory_limit=-1 /usr/local/bin/wp core download --allow-root
RUN wp config create --dbname=db --dbuser=wordpress --prompt=dbpass  --dbpass=${DB_PASS} --dbhost=localhost:3306
RUN wp db create
RUN wp core install --url=wpclidemo.dev --title="WP-INCEPTION" --admin_user=$(ADMIN) --admin_password=$(WP_PASS) --admin_email=jtuomi@student.hive.fi


CMD ["php-fpm", "-F"]
