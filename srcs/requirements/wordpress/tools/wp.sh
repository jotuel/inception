#!/usr/bin/env sh
set -e

WP_ADMIN_USER="${WP_ADMIN_USER:-root}"
WP_ADMIN_PASS="${WP_ADMIN_PASS:-changeme}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@jtuomi.hive.fi}"

if [ ! -f /var/www/html/wp-includes/version.php ]; then
	echo "Downloading WordPress core..."
	/usr/bin/php -dmemory_limit=-1 /usr/local/bin/wp core download --path=/var/www/html --allow-root
fi

wp config create \
  --path=/var/www/html \
  --dbname=wp \
  --dbuser=wordpress \
  --dbpass=world \
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
	  --url=jtuomi.hive.fi \
	  --title=WP-INCEPTION \
	  --admin_user=admin \
	  --admin_password=1234 \
	  --admin_email=jtuomi@student.hive.fi \
	  --skip-email \
	  --allow-root
fi

chown -R nobody:nobody /var/www/html || true

# Start php-fpm in the foreground
exec php-fpm83 -F
