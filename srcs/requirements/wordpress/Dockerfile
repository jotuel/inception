FROM alpine:3
ENV PHP_MEMORY_LIMIT=-1

# Install PHP, php-fpm and tools (no-cache to keep image small)
RUN apk update && apk upgrade && apk add --no-cache php php-cgi fcgi php-fpm php-phar php-mysqli wget bash composer

# Install wp-cli but DO NOT run WP-CLI at build time (defer runtime actions to entrypoint)
RUN mkdir /opt/wordpress \
	&& cd /opt/wordpress \
	&& wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /opt/wordpress/wp-cli.phar \
	&& mv /opt/wordpress/wp-cli.phar /usr/local/bin/wp

# Create webroot (files will be created at runtime by wp-cli in the entrypoint)
RUN mkdir -p /var/www/html && chown -R nobody:nobody /var/www/html

# Configure php-fpm to listen on TCP 0.0.0.0:9000 so nginx (in another container) can reach it
RUN mkdir -p /etc/php7/php-fpm.d && cat > /etc/php7/php-fpm.d/zz-docker.conf <<'EOF'
[www]
; Listen on all interfaces on port 9000 (TCP)
listen = 0.0.0.0:9000

; Basic permissions / user. Adjust if your container uses another user.
listen.owner = nobody
listen.group = nobody

; Pool process management (tweak for production)
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

; Set the user/group under which the pool will run
user = nobody
group = nobody

; Ensure the docroot matches the mounted volume
php_admin_value[open_basedir] = /var/www/html:/tmp
EOF

# Copy the runtime entrypoint which will:
# - wait for the DB to be available
# - run wp-cli commands (download core, create config, run install) at runtime
# - start php-fpm in the foreground
COPY tools/wp.sh /tmp/wordpress.sh
RUN chmod +x /tmp/wordpress.sh

# Expose the php-fpm port to other containers (not the host)
EXPOSE 9000

# Entrypoint performs runtime WP-CLI actions and then runs php-fpm (foreground)
ENTRYPOINT ["/tmp/wordpress.sh"]
