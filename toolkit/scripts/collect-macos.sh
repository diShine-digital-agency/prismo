#!/usr/bin/env bash
# ============================================================
# Prismo — macOS Data Collection Script
# Part of Prismo AI Consulting Toolkit by diShine Digital Agency
# https://dishine.it
#
# Collects comprehensive macOS system data for offline analysis:
#   System info (sw_vers, system_profiler), CPU, memory (vm_stat),
#   disk space (df + diskutil), SMART status, network config,
#   firewall, security (SIP, Gatekeeper, FileVault, XProtect),
#   users, services (launchctl), software updates, recent errors,
#   Time Machine, startup items, uptime.
#
# Usage: bash collect-macos.sh [output_dir]
# ============================================================
set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname -s)
OUTPUT_DIR="${1:-$(pwd)}"
OUTFILE="${OUTPUT_DIR}/prismo_collect_macos_${HOSTNAME}_${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

section() {
    local title="$1"
    printf '\n%s\n  %s\n%s\n' \
        "$(printf '=%.0s' {1..70})" \
        "$title" \
        "$(printf '=%.0s' {1..70})"
}

{

section "PRISMO macOS DATA COLLECTION"
echo "Hostname   : $HOSTNAME"
echo "Collected  : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Script     : Prismo AI Consulting Toolkit — diShine Digital Agency"
echo "User       : $(whoami)"

# ---- System Info ----
section "SYSTEM INFORMATION"
sw_vers 2>/dev/null || echo "  sw_vers not available"
echo ""
echo "Kernel: $(uname -r)"
echo "Arch  : $(uname -m)"
echo ""
echo "--- Hardware Overview ---"
system_profiler SPHardwareDataType 2>/dev/null | grep -E "Model|Processor|Cores|Memory|Serial|UUID" || true

# ---- Uptime ----
section "UPTIME"
uptime

# ---- CPU ----
section "CPU INFORMATION"
sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "  CPU info not available"
echo "Logical CPUs : $(sysctl -n hw.logicalcpu 2>/dev/null || echo 'N/A')"
echo "Physical CPUs: $(sysctl -n hw.physicalcpu 2>/dev/null || echo 'N/A')"
echo "CPU Frequency: $(sysctl -n hw.cpufrequency 2>/dev/null | awk '{printf "%.0f MHz", $1/1000000}' 2>/dev/null || echo 'N/A')"

# ---- Memory ----
section "MEMORY"
echo "Total RAM: $(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.2f GB", $1/1073741824}' 2>/dev/null || echo 'N/A')"
echo ""
echo "--- vm_stat ---"
vm_stat 2>/dev/null || echo "  vm_stat not available"
echo ""
echo "--- Memory Pressure ---"
memory_pressure 2>/dev/null | head -5 || echo "  memory_pressure not available"

# ---- Disk Space ----
section "DISK SPACE"
echo "--- df ---"
df -h 2>/dev/null
echo ""
echo "--- diskutil list ---"
diskutil list 2>/dev/null || echo "  diskutil not available"

# ---- SMART Status ----
section "DISK SMART STATUS"
diskutil info / 2>/dev/null | grep -i "smart\|solid\|protocol\|device" || echo "  SMART info not available"
echo ""
for disk in $(diskutil list 2>/dev/null | grep "^/dev/disk" | awk '{print $1}'); do
    echo "--- $disk ---"
    diskutil info "$disk" 2>/dev/null | grep -iE "SMART|Media Name|Protocol|Solid State" || true
    echo ""
done

# ---- Network Configuration ----
section "NETWORK CONFIGURATION"
echo "--- Active Interfaces ---"
ifconfig 2>/dev/null | grep -E "^[a-z]|inet " || echo "  ifconfig not available"
echo ""
echo "--- Wi-Fi Info ---"
if command -v /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport &>/dev/null; then
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | head -15 || true
else
    networksetup -getairportnetwork en0 2>/dev/null || echo "  Wi-Fi info not available"
fi
echo ""
echo "--- DNS Configuration ---"
scutil --dns 2>/dev/null | grep -E "nameserver|domain|search" | head -15 || echo "  DNS info not available"
echo ""
echo "--- Routing Table ---"
netstat -rn 2>/dev/null | head -20 || echo "  Route info not available"

# ---- Listening Ports ----
section "LISTENING PORTS"
lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | head -30 || netstat -an 2>/dev/null | grep LISTEN | head -30

# ---- Firewall ----
section "FIREWALL"
echo "--- Application Firewall ---"
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "  Firewall status not available"
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null || true
/usr/libexec/ApplicationFirewall/socketfilterfw --getblockall 2>/dev/null || true
echo ""
echo "--- pf (packet filter) ---"
pfctl -s info 2>/dev/null | head -5 || echo "  pf info not available (requires sudo)"

# ---- Security ----
section "SECURITY"
echo "--- System Integrity Protection (SIP) ---"
csrutil status 2>/dev/null || echo "  SIP status not available"
echo ""
echo "--- Gatekeeper ---"
spctl --status 2>/dev/null || echo "  Gatekeeper status not available"
echo ""
echo "--- FileVault ---"
fdesetup status 2>/dev/null || echo "  FileVault status not available"
echo ""
echo "--- XProtect ---"
if [ -f /System/Library/CoreServices/XProtect.bundle/Contents/version.plist ]; then
    defaults read /System/Library/CoreServices/XProtect.bundle/Contents/version.plist CFBundleShortVersionString 2>/dev/null || echo "  Version not readable"
else
    echo "  XProtect bundle not found at expected path."
fi
system_profiler SPInstallHistoryDataType 2>/dev/null | grep -A2 "XProtect" | tail -3 || true

# ---- Users ----
section "USER ACCOUNTS"
echo "--- Current User ---"
id 2>/dev/null
echo ""
echo "--- All Users ---"
dscl . list /Users 2>/dev/null | grep -v "^_" || echo "  User list not available"
echo ""
echo "--- Admin Users ---"
dscl . -read /Groups/admin GroupMembership 2>/dev/null || echo "  Admin group not readable"

# ---- Services (launchctl) ----
section "SERVICES (launchctl)"
echo "--- Running System Daemons (sample) ---"
launchctl list 2>/dev/null | head -30 || echo "  launchctl not available"
echo ""
echo "--- Failed Services ---"
launchctl list 2>/dev/null | awk '$1 != "0" && $1 != "-" && $1 != "PID" {print}' | head -20 || true

# ---- Software Updates ----
section "SOFTWARE UPDATES"
softwareupdate -l 2>/dev/null || echo "  Unable to check for updates."

# ---- Recent Errors (log show) ----
section "RECENT ERRORS (Last 1 Hour)"
log show --predicate 'eventType == logEvent AND messageType == error' --last 1h --style compact 2>/dev/null | head -40 || echo "  Unable to query unified log."

# ---- Time Machine ----
section "TIME MACHINE"
tmutil status 2>/dev/null || echo "  Time Machine not available"
echo ""
tmutil latestbackup 2>/dev/null || echo "  No recent backup found"
echo ""
tmutil destinationinfo 2>/dev/null || echo "  No destination configured"

# ---- Startup Items ----
section "STARTUP ITEMS"
echo "--- Login Items (current user) ---"
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || echo "  Unable to list login items"
echo ""
echo "--- LaunchDaemons ---"
ls /Library/LaunchDaemons/ 2>/dev/null | head -20 || echo "  None found"
echo ""
echo "--- LaunchAgents ---"
ls /Library/LaunchAgents/ 2>/dev/null | head -20 || echo "  None found"
ls ~/Library/LaunchAgents/ 2>/dev/null | head -20 || true

section "END OF REPORT"

} > "$OUTFILE" 2>&1

echo "[Prismo] Report saved to: $OUTFILE"
