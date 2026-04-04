#!/usr/bin/env bash
# ============================================================
# Prismo — Web Data Collection Script
# Part of Prismo AI Consulting Toolkit by diShine Digital Agency
# https://dishine.it
#
# Collects web data from a target URL for offline analysis:
#   HTTP headers, HTML source, meta tags, SSL certificate info,
#   robots.txt, sitemap.xml, response times.
#
# Usage: bash collect-web.sh <url> [output_dir]
#
# Examples:
#   bash collect-web.sh https://example.com
#   bash collect-web.sh https://example.com ./reports
# ============================================================
set -euo pipefail

# ---- Argument Validation ----
if [ $# -lt 1 ]; then
    echo "Usage: bash collect-web.sh <url> [output_dir]"
    echo "Example: bash collect-web.sh https://example.com ./reports"
    exit 1
fi

URL="$1"
OUTPUT_DIR="${2:-$(pwd)}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Extract domain from URL
DOMAIN=$(echo "$URL" | sed -E 's|^https?://||' | sed 's|/.*||' | sed 's|:.*||')
SAFE_DOMAIN=$(echo "$DOMAIN" | tr '.' '_' | tr -cd '[:alnum:]_-')
OUTFILE="${OUTPUT_DIR}/prismo_collect_web_${SAFE_DOMAIN}_${TIMESTAMP}.txt"

# Determine protocol
PROTOCOL=$(echo "$URL" | grep -oE '^https?' || echo "http")
BASE_URL="${PROTOCOL}://${DOMAIN}"

mkdir -p "$OUTPUT_DIR"

section() {
    local title="$1"
    printf '\n%s\n  %s\n%s\n' \
        "$(printf '=%.0s' {1..70})" \
        "$title" \
        "$(printf '=%.0s' {1..70})"
}

# Check for curl
if ! command -v curl &>/dev/null; then
    echo "[Prismo] Error: curl is required but not installed."
    exit 1
fi

{

section "PRISMO WEB DATA COLLECTION"
echo "URL        : $URL"
echo "Domain     : $DOMAIN"
echo "Protocol   : $PROTOCOL"
echo "Collected  : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Script     : Prismo AI Consulting Toolkit — diShine Digital Agency"

# ---- HTTP Headers ----
section "HTTP RESPONSE HEADERS"
curl -sI -L --max-time 15 --max-redirs 5 "$URL" 2>/dev/null || echo "  Failed to fetch HTTP headers."

# ---- Response Times ----
section "RESPONSE TIMES"
echo "--- Timing Breakdown ---"
curl -so /dev/null -w "\
  DNS Lookup     : %{time_namelookup}s\n\
  TCP Connect    : %{time_connect}s\n\
  TLS Handshake  : %{time_appconnect}s\n\
  Start Transfer : %{time_starttransfer}s\n\
  Total Time     : %{time_total}s\n\
  HTTP Code      : %{http_code}\n\
  Download Size  : %{size_download} bytes\n\
  Redirect Count : %{num_redirects}\n\
  Effective URL  : %{url_effective}\n" \
    --max-time 15 -L "$URL" 2>/dev/null || echo "  Failed to measure response times."

# ---- SSL Certificate ----
section "SSL CERTIFICATE"
if [ "$PROTOCOL" = "https" ]; then
    echo "--- Certificate Details ---"
    echo | openssl s_client -servername "$DOMAIN" -connect "${DOMAIN}:443" 2>/dev/null | openssl x509 -noout -text 2>/dev/null | grep -E "Subject:|Issuer:|Not Before|Not After|DNS:" | head -20 || echo "  Failed to retrieve SSL certificate."
    echo ""
    echo "--- Certificate Chain ---"
    echo | openssl s_client -servername "$DOMAIN" -connect "${DOMAIN}:443" -showcerts 2>/dev/null | grep -E "subject=|issuer=|depth=" | head -10 || true
    echo ""
    echo "--- Certificate Expiry ---"
    echo | openssl s_client -servername "$DOMAIN" -connect "${DOMAIN}:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "  Unable to determine expiry."
else
    echo "  Skipped — not HTTPS."
fi

# ---- Meta Tags ----
section "META TAGS"
HTML_CONTENT=$(curl -sL --max-time 15 --max-redirs 5 "$URL" 2>/dev/null || echo "")
if [ -n "$HTML_CONTENT" ]; then
    echo "$HTML_CONTENT" | grep -ioE '<meta[^>]+>' | head -30 || echo "  No meta tags found."
    echo ""
    echo "--- Title Tag ---"
    echo "$HTML_CONTENT" | grep -ioE '<title>[^<]*</title>' | head -1 || echo "  No title tag found."
    echo ""
    echo "--- Canonical ---"
    echo "$HTML_CONTENT" | grep -ioE '<link[^>]*rel=["\x27]canonical["\x27][^>]*>' | head -1 || echo "  No canonical link found."
    echo ""
    echo "--- Open Graph ---"
    echo "$HTML_CONTENT" | grep -ioE '<meta[^>]*property=["\x27]og:[^"'\'']*["\x27][^>]*>' | head -10 || echo "  No OG tags found."
else
    echo "  Failed to fetch HTML content."
fi

# ---- HTML Source (truncated) ----
section "HTML SOURCE (First 200 Lines)"
if [ -n "$HTML_CONTENT" ]; then
    echo "$HTML_CONTENT" | head -200
else
    echo "  No HTML content available."
fi

# ---- robots.txt ----
section "ROBOTS.TXT"
curl -sL --max-time 10 "${BASE_URL}/robots.txt" 2>/dev/null | head -50 || echo "  robots.txt not found or unreachable."

# ---- sitemap.xml ----
section "SITEMAP.XML"
SITEMAP_CONTENT=$(curl -sL --max-time 10 "${BASE_URL}/sitemap.xml" 2>/dev/null || echo "")
if echo "$SITEMAP_CONTENT" | head -5 | grep -qi "xml\|sitemap\|urlset"; then
    echo "$SITEMAP_CONTENT" | head -50
else
    echo "  sitemap.xml not found or not valid XML."
    echo ""
    echo "--- Checking robots.txt for sitemap references ---"
    curl -sL --max-time 10 "${BASE_URL}/robots.txt" 2>/dev/null | grep -i "sitemap" || echo "  No sitemap references found in robots.txt."
fi

# ---- Additional Checks ----
section "ADDITIONAL CHECKS"
echo "--- Security Headers ---"
curl -sI -L --max-time 15 "$URL" 2>/dev/null | grep -iE "strict-transport|content-security|x-frame|x-content-type|x-xss|referrer-policy|permissions-policy|feature-policy" || echo "  No common security headers found."
echo ""
echo "--- Server Technology ---"
curl -sI -L --max-time 15 "$URL" 2>/dev/null | grep -iE "^server:|^x-powered-by:|^x-generator:" || echo "  Server technology not disclosed in headers."

section "END OF REPORT"

} > "$OUTFILE" 2>&1

echo "[Prismo] Report saved to: $OUTFILE"
