#!/bin/bash
mariadb-admin --port=3306 ping >/dev/null 2>&1
if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi
