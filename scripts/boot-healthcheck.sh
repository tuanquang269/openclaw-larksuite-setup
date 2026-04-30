#!/bin/bash
# OpenClaw Boot Health Check — runs every 45s via launchd
# Ensures the gateway service is loaded and the HTTP endpoint is responsive.
# IMPORTANT: Respects a 90-second startup grace period to avoid restart loops during Feishu initialization.

PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
LABEL="ai.openclaw.gateway"
HEALTH_URL="http://127.0.0.1:18789/__openclaw__/health"
LOG_TAG="[boot-healthcheck]"
NOW=$(date '+%Y-%m-%dT%H:%M:%S%z')
STARTUP_GRACE_FILE="/tmp/openclaw-gateway-startup-ts"

# 1. Check if the launchd job is loaded at all
if ! launchctl list "$LABEL" &>/dev/null; then
    echo "$NOW $LOG_TAG gateway launchd job is NOT loaded — reloading"
    launchctl load "$PLIST" 2>&1
    date +%s > "$STARTUP_GRACE_FILE"
    exit 0
fi

# 2. Check if the gateway PID is alive
GW_PID=$(launchctl list "$LABEL" 2>/dev/null | awk '{print $1}')
if [ "$GW_PID" = "-" ] || [ -z "$GW_PID" ]; then
    echo "$NOW $LOG_TAG gateway has no running PID — starting"
    launchctl start "$LABEL" 2>&1
    date +%s > "$STARTUP_GRACE_FILE"
    exit 0
fi

# 3. Startup grace period
if [ -f "$STARTUP_GRACE_FILE" ]; then
    STARTED_AT=$(cat "$STARTUP_GRACE_FILE" 2>/dev/null || echo 0)
    ELAPSED=$(( $(date +%s) - STARTED_AT ))
    if [ "$ELAPSED" -lt 90 ]; then
        exit 0
    fi
fi

# 4. Check if the HTTP health endpoint is reachable
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$HEALTH_URL" 2>/dev/null)
if [ "$HTTP_CODE" != "200" ]; then
    echo "$NOW $LOG_TAG gateway health check failed (HTTP $HTTP_CODE) — restarting"
    launchctl stop "$LABEL" 2>/dev/null
    sleep 2
    launchctl start "$LABEL" 2>/dev/null
    date +%s > "$STARTUP_GRACE_FILE"
fi
