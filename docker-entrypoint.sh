#!/usr/bin/env bash
set -euo pipefail

# ========================================
# CONFIGURATION
# ========================================
DEFAULT_INTERVAL="5"
LOG_FILE="/var/log/amplify-json.log"
CRON_FILE="/etc/cron.d/amplify"
SCRIPT="(/usr/local/bin/amplify-generate && /usr/local/bin/amplify-process)"

# ========================================
# ENVIRONMENT VARIABLES
# ========================================
CRON_EXPRESSION="${CRON_EXPRESSION:-}"
INTERVAL="${INTERVAL:-$DEFAULT_INTERVAL}"

# ===================================
# UTILITIES
# ===================================
abort() {
	echo "ERROR: $1" >&2
	exit 1
}

info() {
	echo "INFO: $1"
}

success() {
	echo "SUCCESS: $1"
}

# ========================================
# FUNCTIONS
# ========================================
create_cronjob() {
	local cron_line="$1"
	# Create the cron job file
	echo "$cron_line root $SCRIPT >> $LOG_FILE 2>&1" >"$CRON_FILE"
	chmod 0644 "$CRON_FILE"
	# Load the cron job into crontab
	crontab "$CRON_FILE"
	info "Cron job created: $cron_line"
}

# ========================================
# MAIN
# ========================================
main() {
	if [[ -n "$CRON_EXPRESSION" ]]; then
		CRON_LINE="$CRON_EXPRESSION"
	else
		if [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
			CRON_LINE="*/$INTERVAL * * * *"
		else
			abort "Invalid INTERVAL value: $INTERVAL"
		fi
	fi
	# Ensure log file and cron directory exist
	info "Setting up log file at $LOG_FILE"
	mkdir -p "$(dirname "$LOG_FILE")"
	touch "$LOG_FILE"
	# Create cron job and run the script once
	create_cronjob "$CRON_LINE"
	bash -c "$SCRIPT" >"$LOG_FILE" 2>&1
	# Start cron service in the background and run the app
	success "Starting cron service..."
	cron && exec "$@"
}

main "$@"
