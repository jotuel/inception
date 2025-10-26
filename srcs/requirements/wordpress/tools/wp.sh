#!/usr/bin/env sh
set -eu
source $CREDENTIALS

if [ ! -f /var/www/html/wp-includes/version.php ]; then
	echo "Downloading WordPress core..."
	/usr/bin/php -dmemory_limit=-1 /usr/local/bin/wp core download --path=/var/www/html --allow-root
fi

wp config create \
  --path=/var/www/html \
  --dbname=wp \
  --dbuser=wordpress \
  --dbpass=$(cat "${WORDPRESS_DB_PASSWORD}") \
  --dbhost=mariadb \
  --skip-check \
  --force

until wp db check --path=/var/www/html --allow-root >/dev/null 2>&1; do
    echo "Waiting for database to be ready..."
    sleep 3
done

if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
	wp core install \
	  --path=/var/www/html \
	  --url=${DOMAIN} \
	  --title=${TITLE} \
	  --admin_user=admin \
	  --admin_password=$(cat "${WORDPRESS_ADMIN_PASSWORD}") \
	  --admin_email=jtuomi@student.hive.fi \
	  --skip-email \
	  --allow-root
fi

chown -R nobody:nobody /var/www/html || true

# Start php-fpm in the foreground
exec php-fpm83 -F
