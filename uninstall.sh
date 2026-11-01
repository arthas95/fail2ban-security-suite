#!/usr/bin/env bash
# ==============================================================================
# Fail2Ban Security Suite - Clean Uninstaller & Rollback
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root." >&2
   exit 1
fi

echo "Removing custom Fail2ban security suite jails and filters..."

rm -f /etc/fail2ban/jail.d/10-sshd.local
rm -f /etc/fail2ban/jail.d/20-postfix.local
rm -f /etc/fail2ban/jail.d/30-dovecot.local
rm -f /etc/fail2ban/jail.d/40-apache.local
rm -f /etc/fail2ban/jail.d/50-squid.local
rm -f /etc/fail2ban/jail.d/60-mariadb.local
rm -f /etc/fail2ban/jail.d/70-named.local
rm -f /etc/fail2ban/jail.d/90-recidive.local

rm -f /etc/fail2ban/filter.d/apache-scanners.conf
rm -f /etc/fail2ban/filter.d/squid-custom.conf
rm -f /etc/fail2ban/filter.d/named-refused-custom.conf

rm -f /usr/local/bin/f2b-status

echo "Restarting Fail2ban..."
systemctl restart fail2ban

echo "Custom suite removed."
