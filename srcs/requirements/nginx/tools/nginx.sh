#!/usr/bin/env sh
set -e

CERT_DIR="/run/secrets"
CERT_FILE="$CERT_DIR/server.cert"
KEY_FILE="$CERT_DIR/server.key"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  mkdir -p "$CERT_DIR"
  openssl req -x509 -nodes -days 365 \
    -subj "/CN=localhost" \
    -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE"
fi

mkdir -p /var/log/nginx /var/www/html

exec nginx -g 'daemon off;'
