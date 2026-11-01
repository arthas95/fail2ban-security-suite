#!/usr/bin/env bash
# ==============================================================================
# Fail2Ban Security Suite - Automated Installer & Hardening Deployment
# Author: Adel Sadek (https://github.com/arthas95)
# Repository: https://github.com/arthas95/fail2ban-security-suite
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}        Fail2Ban Security Suite - Automated Installer             ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# 1. Root verification
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root.${NC}" >&2
   exit 1
fi

# 2. Package verification
if ! command -v fail2ban-client >/dev/null 2>&1; then
    echo -e "${YELLOW}[INFO] Fail2Ban not detected. Installing fail2ban, iptables & python3-systemd...${NC}"
    apt-get update -qq
    apt-get install -y fail2ban iptables python3-systemd
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

echo -e "${GREEN}[+] Installing custom filters in /etc/fail2ban/filter.d/...${NC}"
mkdir -p /etc/fail2ban/filter.d
cp -v "$CONFIG_DIR/filter.d/"*.conf /etc/fail2ban/filter.d/

echo -e "${GREEN}[+] Installing modular jails in /etc/fail2ban/jail.d/...${NC}"
mkdir -p /etc/fail2ban/jail.d
for conf in "$CONFIG_DIR/jail.d/"*.conf; do
    basename_no_ext="$(basename "$conf" .conf)"
    cp -v "$conf" "/etc/fail2ban/jail.d/${basename_no_ext}.local"
done

# 3. Setup jail.local whitelist
if [ ! -f /etc/fail2ban/jail.local ]; then
    echo -e "${YELLOW}[*] Generating /etc/fail2ban/jail.local...${NC}"
    # Auto-detect primary IP
    PRIMARY_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -n1 || echo "")
    
    cp "$CONFIG_DIR/jail.local.template" /etc/fail2ban/jail.local
    if [ -n "$PRIMARY_IP" ]; then
        sed -i "s|<YOUR_SERVER_PUBLIC_IP>|$PRIMARY_IP|g" /etc/fail2ban/jail.local
    fi
    sed -i "s|<YOUR_ADMIN_IP>||g" /etc/fail2ban/jail.local
    echo -e "${GREEN}[+] Configured /etc/fail2ban/jail.local (Review ignoreip to add your trusted IPs).${NC}"
else
    echo -e "${BLUE}[*] Preserving existing /etc/fail2ban/jail.local${NC}"
fi

# 4. Install dashboard utility
if [ -f "$SCRIPT_DIR/scripts/f2b-status.sh" ]; then
    echo -e "${GREEN}[+] Installing dashboard command: /usr/local/bin/f2b-status${NC}"
    cp "$SCRIPT_DIR/scripts/f2b-status.sh" /usr/local/bin/f2b-status
    chmod +x /usr/local/bin/f2b-status
fi

# 5. Configuration syntax verification
echo -e "${YELLOW}[*] Validating Fail2Ban configuration syntax...${NC}"
if fail2ban-client -t; then
    echo -e "${GREEN}[+] Configuration syntax is VALID!${NC}"
else
    echo -e "${RED}[ERROR] Syntax error detected in Fail2ban configuration! Aborting reload.${NC}" >&2
    exit 1
fi

# 6. Enable and restart service
echo -e "${GREEN}[+] Enabling and restarting Fail2Ban service...${NC}"
systemctl enable fail2ban
systemctl restart fail2ban

echo -e "${GREEN}[+] Waiting for jails to initialize...${NC}"
sleep 2

# 7. Print summary
if [ -f /usr/local/bin/f2b-status ]; then
    /usr/local/bin/f2b-status
fi

echo -e "${GREEN}==================================================================${NC}"
echo -e "${GREEN}        Installation and Hardening Completed Successfully!        ${NC}"
echo -e "${GREEN}==================================================================${NC}"
