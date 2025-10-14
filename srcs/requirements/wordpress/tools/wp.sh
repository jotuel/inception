until wp db-check --path=/var/www/html > /dev/null 2>&1; do
	sleep 2
done

wp core install --url=wpclidemo.dev --title="WP-INCEPTION" --admin_user=$(ADMIN) --admin_password=$(WP_PASS) --admin_email=jtuomi@student.hive.fi
exec "php-fpm", "-F"
