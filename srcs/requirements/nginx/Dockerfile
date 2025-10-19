FROM alpine:3

# Install nginx and openssl to generate a self-signed cert at container start
RUN apk update && apk upgrade && apk add --no-cache nginx openssl bash

# Copy your nginx server block into http.d (nginx's main config includes http.d/*.conf)
COPY ./conf/nginx.conf.conf /etc/nginx/http.d/nginx.conf

# Create an entrypoint script that will generate a self-signed certificate
RUN mkdir -p /run/secrets \
 && cat > /usr/local/bin/docker-entrypoint.sh <<'EOF'
#!/usr/bin/env sh
set -e

CERT_DIR="/run/secrets"
CERT_FILE="$CERT_DIR/server.cert"
KEY_FILE="$CERT_DIR/server.key"

# Generate a simple self-signed certificate if missing
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "Generating self-signed certificate for nginx..."
  mkdir -p "$CERT_DIR"
  openssl req -x509 -nodes -days 365 \
    -subj "/CN=localhost" \
    -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE"
fi

# Ensure necessary directories exist
mkdir -p /var/log/nginx /var/www/html

# Start nginx in the foreground so the container keeps running
exec nginx -g 'daemon off;'
EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80 443

CMD ["/usr/local/bin/docker-entrypoint.sh"]
