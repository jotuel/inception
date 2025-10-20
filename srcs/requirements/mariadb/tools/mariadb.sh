#!/usr/bin/env sh

set -eu

DATADIR=${DATADIR:-/var/lib/mysql}
BIND_ADDRESS=${BIND_ADDRESS:-127.0.0.1}
PORT=${PORT:-3306}
TMP_LOG=${TMP_LOG:-/tmp/mariadb-init.log}
FLAG_FILE=${FLAG_FILE:-"${DATADIR}/.mariadb_initialized"}

DB_NAME=${MARIADB_DATABASE:-wordpress}
DB_USER=${MARIADB_USER:-wordpress}

# Read secrets
if [ -n "${MARIADB_ROOT_PASSWORD_FILE:-}" ] && [ -f "${MARIADB_ROOT_PASSWORD_FILE}" ]; then
  ROOT_PASS=$(cat "${MARIADB_ROOT_PASSWORD_FILE}")
else
  ROOT_PASS=${MARIADB_ROOT_PASSWORD:-}
fi

if [ -n "${MARIADB_PASSWORD_FILE:-}" ] && [ -f "${MARIADB_PASSWORD_FILE}" ]; then
  DB_PASS=$(cat "${MARIADB_PASSWORD_FILE}")
else
  DB_PASS=${MARIADB_PASSWORD:-}
fi

# If already initialized, exec final server
if [ -f "$FLAG_FILE" ]; then
  exec mariadbd --user=mysql --datadir="$DATADIR"
fi

mariadb -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
mariadb -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
mariadb -e "FLUSH PRIVILEGES;"
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASS';"
mariadb -e "ALTER USER 'root'@'%' IDENTIFIED BY '$ROOT_PASS';"
mariadb -e "FLUSH PRIVILEGES";

touch "$FLAG_FILE"

exec mariadbd --user=mysql --datadir="$DATADIR" --console
