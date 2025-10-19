#!/usr/bin/env sh
set -e

# Load DB password from file if provided (Docker secrets pattern)
if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
  WP_DB_PASS=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
else
  WP_DB_PASS="${WORDPRESS_DB_PASSWORD:-}"
fi

WP_DB_HOST="${WORDPRESS_DB_HOST:-mariadb:3306}"
WP_DB_USER="${WORDPRESS_DB_USER:-wordpress}"
WP_DB_NAME="${WORDPRESS_DB_NAME:-wordpress}"
WP_ADMIN_USER="${WP_ADMIN_USER:-admin}"
WP_ADMIN_PASS="${WP_ADMIN_PASS:-changeme}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@localhost}"
WP_URL="${DOMAIN:-http://localhost}"

# Wait until the database is reachable via wp-cli
echo "Waiting for database at ${WP_DB_HOST}..."
until wp db check --path=/var/www/html --allow-root > /dev/null 2>&1; do
	sleep 2
done

# Ensure WordPress core files exist
if [ ! -f /var/www/html/wp-includes/version.php ]; then
	echo "Downloading WordPress core..."
	wp core download --path=/var/www/html --allow-root
fi

# Create wp-config.php if missing
if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Creating wp-config.php..."
	wp config create \
	  --path=/var/www/html \
	  --dbname="$WP_DB_NAME" \
	  --dbuser="$WP_DB_USER" \
	  --dbpass="$WP_DB_PASS" \
	  --dbhost="$WP_DB_HOST" \
	  --skip-check \
	  --allow-root
fi

# Run the installer if WordPress isn't installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
	echo "Installing WordPress..."
	wp core install \
	  --path=/var/www/html \
	  --url="$WP_URL" \
	  --title="WP-INCEPTION" \
	  --admin_user="$WP_ADMIN_USER" \
	  --admin_password="$WP_ADMIN_PASS" \
	  --admin_email="$WP_ADMIN_EMAIL" \
	  --skip-email \
	  --allow-root
fi

# Ensure correct ownership (best-effort)
chown -R nobody:nobody /var/www/html || true

# Start php-fpm in the foreground
exec php-fpm -F
