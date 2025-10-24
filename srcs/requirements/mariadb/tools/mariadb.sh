#!/usr/bin/env sh
set -eu

DB_NAME=${MARIADB_DATABASE:-wordpress}
DB_USER=${MARIADB_USER:-wordpress}

if [ -n "${MARIADB_ROOT_PASSWORD:-}" ] && [ -f "${MARIADB_ROOT_PASSWORD}" ]; then
  ROOT_PASS=$(cat "${MARIADB_ROOT_PASSWORD}")
else
  ROOT_PASS=${MARIADB_ROOT_PASSWORD:-}
fi

if [ -n "${MARIADB_PASSWORD:-}" ] && [ -f "${MARIADB_PASSWORD}" ]; then
  DB_PASS=$(cat "${MARIADB_PASSWORD_FILE}")
else
  DB_PASS=${MARIADB_PASSWORD:-}
fi

exec mariadbd --console
