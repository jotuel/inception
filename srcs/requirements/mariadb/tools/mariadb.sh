#!/usr/bin/env sh

: "${MARIA:?Environment variable myMariaPass is required}"
: "${MARIA_ROOT:?Environment variable MariaBossPass is required}"

# Check if USER is set and non-empty
if [ -n "$USER" ]; then
    USERNAME="$USER"
else
    USERNAME="DEFAULTUSER"
fi

ADMIN="root"

USER="wordpress"

service mysql start

mysql -e "CREATE DATABASE IF NOT EXISTS ${USER};"
mysql -e "CREATE USER '${USERNAME}'@'%' IDENTIFIED BY '${USER}';"
mysql -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${USERNAME}'@'%';"

mysql -e "CREATE USER '${ADMIN}'@'%' IDENTIFIED BY '${USER}';"
mysql -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${ADMIN}'@'%';"

mysql -e "FLUSH PRIVILEGES;"

exec mysqld_safe
