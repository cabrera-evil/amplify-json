#!/usr/bin/env bash
set -euo pipefail

# ========================================
# CONFIGURATION
# ========================================
DEFAULT_INTERVAL="5"
LOG_FILE="/var/log/amplify-json.log"
CRON_FILE="/etc/cron.d/amplify"
SCRIPT="amplify-generate && amplify-process"

# ========================================
# ENVIRONMENT VARIABLES
# ========================================
CRON_EXPRESSION="${CRON_EXPRESSION:-}"
INTERVAL="${INTERVAL:-$DEFAULT_INTERVAL}"

# ========================================
# FUNCTIONS
# ========================================
log() {
  echo -e "\033[1;34m› [entrypoint] $1\033[0m"
}

create_cronjob() {
  local cron_line="$1"
  log "Creating cronjob with expression: $cron_line"
  echo "$cron_line root $SCRIPT >> $LOG_FILE 2>&1" >"$CRON_FILE"
  chmod 0644 "$CRON_FILE"
}

run_once() {
  log "Running scripts for the first time..."
  bash -c "$SCRIPT"
}

# ========================================
# MAIN
# ========================================

# Validate cron expression or fallback to interval
if [[ -n "$CRON_EXPRESSION" ]]; then
  CRON_LINE="$CRON_EXPRESSION"
else
  if [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    CRON_LINE="*/$INTERVAL * * * *"
  else
    echo "[entrypoint] Invalid INTERVAL value: $INTERVAL" >&2
    exit 1
  fi
fi

# Ensure log file and cron directory exist
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

create_cronjob "$CRON_LINE"
run_once

log "Starting CMD: $*"
exec "$@"
