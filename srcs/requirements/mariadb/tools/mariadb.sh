#!/usr/bin/env sh
# mariadb initialization script
# - If the database is uninitialized, start a temporary mariadbd for initialization (skip networking),
#   create database/user/root password from secrets/env, then stop the temporary server and
#   exec the final mariadbd in foreground.
#
# This script expects the mariadb server binary `mariadbd` and client `mariadb` available in PATH.
# It reads optional secret files:
#   MARIADB_ROOT_PASSWORD_FILE -> file containing root password
#   MARIADB_PASSWORD_FILE      -> file containing application DB user password
#
# Environment fallbacks:
#   MARIADB_ROOT_PASSWORD, MARIADB_PASSWORD, MARIADB_DATABASE, MARIADB_USER
set -eu

# Configuration
DATADIR=${DATADIR:-/var/lib/mysql}
SOCKET_DIR=${SOCKET_DIR:-/run/mysqld}
SOCKET=${SOCKET_DIR}/mysqld.sock
FLAG_FILE=${DATADIR}/.mariadb_initialized
TMP_LOG=/tmp/mariadb-init.log

DB_NAME=${MARIADB_DATABASE:-wordpress}
DB_USER=${MARIADB_USER:-wordpress}

# Read secrets if provided
if [ -n "${MARIADB_ROOT_PASSWORD_FILE:-}" ] && [ -f "${MARIADB_ROOT_PASSWORD_FILE}" ]; then
  ROOT_PASS="$(cat "${MARIADB_ROOT_PASSWORD_FILE}")"
else
  ROOT_PASS="${MARIADB_ROOT_PASSWORD:-}"
fi

if [ -n "${MARIADB_PASSWORD_FILE:-}" ] && [ -f "${MARIADB_PASSWORD_FILE}" ]; then
  DB_PASS="$(cat "${MARIADB_PASSWORD_FILE}")"
else
  DB_PASS="${MARIADB_PASSWORD:-}"
fi

# Ensure datadir and socket dir exist with correct ownership
mkdir -p "$DATADIR" "$SOCKET_DIR" /var/run/mysqld 2>/dev/null || true
chown -R mysql:mysql "$DATADIR" "$SOCKET_DIR" /var/run/mysqld 2>/dev/null || true
chmod 750 "$SOCKET_DIR" 2>/dev/null || true

# If already initialized, just exec mariadbd
if [ -f "$FLAG_FILE" ]; then
  echo "MariaDB: already initialized, exec mariadbd"
  exec mariadbd --user=mysql --datadir="$DATADIR"
fi

# Start temporary mariadbd for initialization (no networking, uses socket)
echo "MariaDB: starting temporary mariadbd for initialization..."
mariadbd --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" \
  --log-error="$TMP_LOG" >/dev/null 2>&1 &

MARIADB_INIT_PID=$!
# Wait for socket to appear and server to accept commands
echo "MariaDB: waiting for server socket at $SOCKET ..."
TRIES=0
MAX_TRIES=60
until [ -S "$SOCKET" ] && mariadb --protocol=socket -S "$SOCKET" -e "SELECT 1" >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -gt "$MAX_TRIES" ]; then
    echo "MariaDB: temporary server did not start within timeout. Last $MAX_TRIES seconds." >&2
    echo "MariaDB: init log follows:" >&2
    sed -n '1,200p' "$TMP_LOG" >&2 || true
    kill "$MARIADB_INIT_PID" >/dev/null 2>&1 || true
    exit 1
  fi
  sleep 1
done
echo "MariaDB: temporary server ready."

# Helper to run SQL via socket as root (no password expected for socket root access on many setups)
run_sql() {
  # Accepts SQL on stdin
  mariadb --protocol=socket -S "$SOCKET" --connect-timeout=2 -u root "$@" 2>/dev/null
}

# Try several approaches to connect as root (some installations use unix_socket auth)
# We'll attempt without password first, then with root password if provided.
CAN_CONNECT_AS_ROOT=0
if run_sql -e "SELECT 1;" >/dev/null 2>&1; then
  CAN_CONNECT_AS_ROOT=1
else
  if [ -n "$ROOT_PASS" ]; then
    if mariadb --protocol=socket -S "$SOCKET" -u root -p"$ROOT_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
      CAN_CONNECT_AS_ROOT=1
    fi
  fi
fi

if [ "$CAN_CONNECT_AS_ROOT" -ne 1 ]; then
  echo "MariaDB: unable to connect as root to temporary server for initialization." >&2
  echo "MariaDB: init log (tail):" >&2
  tail -n +1 "$TMP_LOG" >&2 || true
  kill "$MARIADB_INIT_PID" >/dev/null 2>&1 || true
  exit 1
fi

# Prepare SQL statements for initialization
SQL_INIT="/tmp/mariadb_init.$$.sql"
rm -f "$SQL_INIT"
cat > "$SQL_INIT" <<'SQL'
SET @@SESSION.SQL_LOG_BIN=0;
FLUSH PRIVILEGES;
SQL

# Create application database
cat >> "$SQL_INIT" <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

# Create or update application user
if [ -n "$DB_PASS" ]; then
  # Create user with password and grant
  cat >> "$SQL_INIT" <<SQL
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '${DB_PASS}';
ALTER USER '$DB_USER'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
SQL
else
  cat >> "$SQL_INIT" <<SQL
CREATE USER IF NOT EXISTS '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
SQL
fi

# Set root password if provided (best-effort)
if [ -n "$ROOT_PASS" ]; then
  # Use ALTER USER to set password for root@localhost and root@%
  cat >> "$SQL_INIT" <<SQL
-- Set root password (may fail on some auth plugin configs; tolerated)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}' ;
ALTER USER 'root'@'%' IDENTIFIED BY '${ROOT_PASS}' ;
FLUSH PRIVILEGES;
SQL
fi

# Execute initialization SQL
echo "MariaDB: running initialization SQL..."
if ! mariadb --protocol=socket -S "$SOCKET" < "$SQL_INIT"; then
  echo "MariaDB: initialization SQL failed. Showing init log:" >&2
  sed -n '1,200p' "$TMP_LOG" >&2 || true
  rm -f "$SQL_INIT"
  kill "$MARIADB_INIT_PID" >/dev/null 2>&1 || true
  exit 1
fi
rm -f "$SQL_INIT"

# Mark initialized
touch "$FLAG_FILE"
chown mysql:mysql "$FLAG_FILE" 2>/dev/null || true

# Stop temporary server gracefully
echo "MariaDB: shutting down temporary server..."
# try mysqladmin shutdown via socket
if mariadb --protocol=socket -S "$SOCKET" -e "SHUTDOWN;" >/dev/null 2>&1; then
  sleep 1
fi
# If still running, kill the PID
if kill -0 "$MARIADB_INIT_PID" >/dev/null 2>&1; then
  kill "$MARIADB_INIT_PID" >/dev/null 2>&1 || true
  # wait for it to exit
  WAIT=0
  while kill -0 "$MARIADB_INIT_PID" >/dev/null 2>&1 && [ "$WAIT" -lt 10 ]; do
    sleep 1
    WAIT=$((WAIT+1))
  done
fi

echo "MariaDB: initialization complete. Launching mariadbd in foreground..."

# Ensure permissions before exec
chown -R mysql:mysql "$DATADIR" "$SOCKET_DIR" 2>/dev/null || true

# Exec final server (foreground)
exec mariadbd --user=mysql --datadir="$DATADIR"
