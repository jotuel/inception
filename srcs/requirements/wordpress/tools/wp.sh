#!/usr/bin/env sh
set -e

WP_ADMIN_USER="${WP_ADMIN_USER:-root}"
WP_ADMIN_PASS="${WP_ADMIN_PASS:-changeme}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@jtuomi.hive.fi}"

if [ ! -f /var/www/html/wp-includes/version.php ]; then
	echo "Downloading WordPress core..."
	/usr/bin/php -dmemory_limit=-1 /usr/local/bin/wp core download --path=/var/www/html --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Creating wp-config.php..."
	wp config create \
	  --path=/var/www/html \
	  --dbname="$WORDPRESS_DB_NAME" \
	  --dbuser="$WORDPRESS_DB_USER" \
	  --dbpass="$WORDPRESS_DB_PASSWORD" \
	  --dbhost="$WORDPRESS_DB_HOST" \
      --skip-check \
	  --allow-root
fi


if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
	echo "Installing WordPress..."
	wp core install \
	  --path=/var/www/html \
	  --url="$DOMAIN" \
	  --title="WP-INCEPTION" \
	  --admin_user="$WP_ADMIN_USER" \
	  --admin_password="$WP_ADMIN_PASS" \
	  --admin_email="$WP_ADMIN_EMAIL" \
	  --skip-email \
	  --skip-check \
	  --allow-root
fi

chown -R nobody:nobody /var/www/html || true

# Start php-fpm in the foreground
exec php-fpm83 -F
