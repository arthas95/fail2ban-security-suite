#!/usr/bin/env bash
# Fail2Ban Multi-Jail Live Status Dashboard
# https://github.com/arthas95/fail2ban-security-suite

set -e

if ! command -v fail2ban-client >/dev/null 2>&1; then
    echo "Error: fail2ban-client is not installed or not in PATH." >&2
    exit 1
fi

echo "================================================================================"
echo "                   Fail2Ban Live Security Dashboard                             "
echo "================================================================================"
printf "%-18s %-10s %-12s %-12s %s\n" "JAIL" "STATUS" "FAILED" "TOTAL BANNED" "ACTIVE BANS"
echo "--------------------------------------------------------------------------------"

JAILS=$(fail2ban-client status 2>/dev/null | grep "Jail list" | sed -E 's/^[^:]+:[ \t]*//' | tr ',' ' ')

if [ -z "$JAILS" ]; then
    echo "No active jails found. Ensure fail2ban is running: systemctl status fail2ban"
    exit 0
fi

TOTAL_CURRENT_BANS=0

for JAIL in $JAILS; do
    STATUS_OUT=$(fail2ban-client status "$JAIL" 2>/dev/null)
    FAILED=$(echo "$STATUS_OUT" | grep "Currently failed:" | awk '{print $NF}')
    TOTAL_BANNED=$(echo "$STATUS_OUT" | grep "Total banned:" | awk '{print $NF}')
    CURRENT_BANS=$(echo "$STATUS_OUT" | grep "Currently banned:" | awk '{print $NF}')
    BANNED_IPS=$(echo "$STATUS_OUT" | grep "Banned IP list:" | sed 's/.*Banned IP list://' | sed 's/^[ \t]*//')

    TOTAL_CURRENT_BANS=$((TOTAL_CURRENT_BANS + ${CURRENT_BANS:-0}))

    if [ -z "$BANNED_IPS" ]; then
        BANNED_IPS="none"
    fi

    printf "%-18s %-10s %-12s %-12s %s\n" "$JAIL" "ACTIVE" "${FAILED:-0}" "${TOTAL_BANNED:-0}" "$BANNED_IPS"
done

echo "================================================================================"
echo "Active Jails: $(echo $JAILS | wc -w) | Total Currently Banned IPs: $TOTAL_CURRENT_BANS"
echo "================================================================================"
