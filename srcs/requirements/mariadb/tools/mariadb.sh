#!/usr/bin/env sh

# Check if USER is set and non-empty
if [ -n "$USER" ]; then
    USERNAME="$USER"
else
    USERNAME="DEFAULTUSER"
fi

FLAG=/tmp/flag

if [ -f $FLAG ]; then 
	exit 0
fi

ADMIN="root"
USER="wordpress"

service mariadb start
mariadb -e "CREATE DATABASE IF NOT EXISTS ${USER};"
mariadb -e "CREATE USER '${USERNAME}'@'%' IDENTIFIED BY '${USER}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${USERNAME}'@'%';"
mariadb -e "CREATE USER '${ADMIN}'@'%' IDENTIFIED BY '${USER}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${USER}.* TO '${ADMIN}'@'%';"
mariadb -e "FLUSH PRIVILEGES;"
mkdir /run/mysqld && touch /run/mysqld/mysqld.sock
exec mariadbd --user=root
