#!/usr/bin/env sh
set -eu

DB_NAME=${MARIADB_DATABASE:-wordpress}
DB_USER=${WORDPRESS_DB_USER:-wordpress}

if [ -n "${MARIADB_ROOT_PASSWORD:-}" ] && [ -f "${MARIADB_ROOT_PASSWORD}" ]; then
  ROOT_PASS=$(cat "${MARIADB_ROOT_PASSWORD}")
else
  ROOT_PASS=${MARIADB_ROOT_PASSWORD:-}
fi

if [ -n "${MARIADB_PASSWORD:-}" ] && [ -f "${MARIADB_PASSWORD}" ]; then
  DB_PASS=$(cat "${MARIADB_PASSWORD}")
else
  DB_PASS=${MARIADB_PASSWORD:-}
fi

export DB_NAME DB_USER DB_PASS ROOT_PASS
envsubst < /tmp/init.sql > /etc/mysql/init.sql

exec mariadbd --console
