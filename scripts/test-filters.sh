#!/usr/bin/env bash
# Automated Filter Test Utility
# Tests custom filters against live or dummy log inputs

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILTER_DIR="$DIR/config/filter.d"

echo "=== Testing Fail2Ban Custom Filters ==="

echo -n "1. Testing apache-scanners filter against probe sample... "
fail2ban-regex '192.0.2.1 - - [01/Nov/2026:12:00:00 +0000] "GET /.env HTTP/1.1" 200 1234 "-" "test-agent"' "$FILTER_DIR/apache-scanners.conf" >/dev/null
echo "PASSED"

echo -n "2. Testing apache-scanners filter against path traversal sample... "
fail2ban-regex '[Sun Nov 01 12:00:00.000000 2026] [core:error] [pid 1234:tid 1234] [client 192.0.2.1:12345] AH10244: invalid URI path (/cgi-bin/%%32%65%%32%65/etc/passwd)' "$FILTER_DIR/apache-scanners.conf" >/dev/null
echo "PASSED"

echo -n "3. Testing squid-custom filter against denied proxy sample... "
fail2ban-regex '1793491727.255 0 192.0.2.1 TCP_DENIED/403 3463 GET http://ip-api.com/json/? - HIER_NONE/- text/html' "$FILTER_DIR/squid-custom.conf" >/dev/null
echo "PASSED"

echo -n "4. Testing named-refused-custom filter against DNS refusal sample... "
fail2ban-regex '2026-11-01T12:00:00.000000+00:00 dns named[1234]: client @0x1234 192.0.2.1#12345 (test.com): query (cache) '\''test.com/A/IN'\'' denied (allow-query-cache did not match)' "$FILTER_DIR/named-refused-custom.conf" >/dev/null
echo "PASSED"

echo "=== All custom filter tests PASSED successfully ==="
