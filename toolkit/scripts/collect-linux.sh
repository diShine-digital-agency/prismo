#!/usr/bin/env bash
# ============================================================
# Prismo — Linux Data Collection Script
# Part of Prismo AI Consulting Toolkit by diShine Digital Agency
# https://dishine.it
#
# Collects comprehensive Linux system data for offline analysis:
#   OS info, uptime/load, CPU, memory, disk (space + inodes),
#   mount points, critical services, journal errors (24h),
#   network config, listening ports, active connections,
#   firewall rules, top processes, logged users, crontab,
#   pending updates, SUID files, SSH configuration.
#
# Usage: bash collect-linux.sh [output_dir]
# ============================================================
set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname)
OUTPUT_DIR="${1:-$(pwd)}"
OUTFILE="${OUTPUT_DIR}/prismo_collect_linux_${HOSTNAME}_${TIMESTAMP}.txt"

mkdir -p "$OUTPUT_DIR"

section() {
    local title="$1"
    printf '\n%s\n  %s\n%s\n' \
        "$(printf '=%.0s' {1..70})" \
        "$title" \
        "$(printf '=%.0s' {1..70})"
}

{

section "PRISMO LINUX DATA COLLECTION"
echo "Hostname   : $HOSTNAME"
echo "Collected  : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Script     : Prismo AI Consulting Toolkit — diShine Digital Agency"
echo "User       : $(whoami)"

# ---- OS Info ----
section "OPERATING SYSTEM"
if [ -f /etc/os-release ]; then
    cat /etc/os-release
elif [ -f /etc/redhat-release ]; then
    cat /etc/redhat-release
else
    uname -a
fi
echo ""
echo "Kernel: $(uname -r)"
echo "Arch  : $(uname -m)"

# ---- Uptime & Load ----
section "UPTIME & LOAD"
uptime
echo ""
cat /proc/loadavg 2>/dev/null || true

# ---- CPU ----
section "CPU INFORMATION"
if command -v lscpu &>/dev/null; then
    lscpu | grep -E "^(Architecture|CPU\(s\)|Model name|Thread|Core|Socket|CPU MHz|Virtualization)"
else
    grep -m1 "model name" /proc/cpuinfo
    grep -c "^processor" /proc/cpuinfo | xargs -I{} echo "Logical CPUs: {}"
fi

# ---- Memory ----
section "MEMORY"
free -h 2>/dev/null || cat /proc/meminfo | head -5
echo ""
echo "--- Swap ---"
swapon --show 2>/dev/null || cat /proc/swaps 2>/dev/null || echo "No swap info available."

# ---- Disk Space ----
section "DISK SPACE"
df -hT 2>/dev/null || df -h

# ---- Inodes ----
section "INODE USAGE"
df -i 2>/dev/null | head -20

# ---- Mount Points ----
section "MOUNT POINTS"
mount | column -t 2>/dev/null || mount

# ---- Critical Services ----
section "CRITICAL SERVICES"
CRITICAL_SERVICES="sshd nginx apache2 httpd mysqld mariadb postgresql docker containerd kubelet cron rsyslog systemd-journald firewalld ufw NetworkManager"
if command -v systemctl &>/dev/null; then
    for svc in $CRITICAL_SERVICES; do
        status=$(systemctl is-active "$svc" 2>/dev/null || echo "not-found")
        if [ "$status" != "not-found" ]; then
            printf "  %-25s %s\n" "$svc" "$status"
        fi
    done
else
    echo "  systemctl not available — skipping."
fi

# ---- Journal Errors (24h) ----
section "LOG ERRORS (Last 24 Hours)"
if command -v journalctl &>/dev/null; then
    journalctl --since "24 hours ago" -p err --no-pager -n 50 2>/dev/null || echo "  No errors or insufficient permissions."
else
    echo "  journalctl not available."
    if [ -f /var/log/syslog ]; then
        echo "  --- Last 30 error lines from /var/log/syslog ---"
        grep -i "error\|fail\|critical" /var/log/syslog 2>/dev/null | tail -30
    fi
fi

# ---- Network Configuration ----
section "NETWORK CONFIGURATION"
if command -v ip &>/dev/null; then
    ip -br addr 2>/dev/null
    echo ""
    echo "--- Default Route ---"
    ip route show default 2>/dev/null
else
    ifconfig 2>/dev/null || echo "  No network tools found."
fi
echo ""
echo "--- DNS ---"
cat /etc/resolv.conf 2>/dev/null | grep -v "^#" | grep -v "^$"

# ---- Listening Ports ----
section "LISTENING PORTS"
if command -v ss &>/dev/null; then
    ss -tulnp 2>/dev/null | head -40
else
    netstat -tulnp 2>/dev/null | head -40
fi

# ---- Active Connections ----
section "ACTIVE CONNECTIONS (ESTABLISHED)"
if command -v ss &>/dev/null; then
    ss -tnp state established 2>/dev/null | head -30
else
    netstat -tnp 2>/dev/null | grep ESTABLISHED | head -30
fi

# ---- Firewall ----
section "FIREWALL"
if command -v ufw &>/dev/null; then
    echo "--- UFW Status ---"
    ufw status verbose 2>/dev/null || echo "  UFW not active or insufficient permissions."
fi
if command -v iptables &>/dev/null; then
    echo ""
    echo "--- iptables (filter) ---"
    iptables -L -n --line-numbers 2>/dev/null | head -40 || echo "  Insufficient permissions for iptables."
fi
if command -v firewall-cmd &>/dev/null; then
    echo ""
    echo "--- firewalld ---"
    firewall-cmd --list-all 2>/dev/null || echo "  firewalld not active."
fi
if command -v nft &>/dev/null; then
    echo ""
    echo "--- nftables ---"
    nft list ruleset 2>/dev/null | head -30 || echo "  Insufficient permissions for nftables."
fi

# ---- Top Processes ----
section "TOP 15 PROCESSES BY MEMORY"
ps aux --sort=-%mem 2>/dev/null | head -16 || ps aux | sort -k4 -rn | head -16

# ---- Logged Users ----
section "LOGGED-IN USERS"
w 2>/dev/null || who 2>/dev/null

# ---- Crontab ----
section "CRONTAB (Current User)"
crontab -l 2>/dev/null || echo "  No crontab for $(whoami)."
echo ""
echo "--- System cron ---"
ls -la /etc/cron.d/ 2>/dev/null || true
ls -la /etc/cron.daily/ 2>/dev/null || true

# ---- Pending Updates ----
section "PENDING UPDATES"
if command -v apt &>/dev/null; then
    apt list --upgradable 2>/dev/null | head -20
elif command -v yum &>/dev/null; then
    yum check-update 2>/dev/null | head -20 || true
elif command -v dnf &>/dev/null; then
    dnf check-update 2>/dev/null | head -20 || true
elif command -v zypper &>/dev/null; then
    zypper list-updates 2>/dev/null | head -20
else
    echo "  Package manager not detected."
fi

# ---- SUID Files ----
section "SUID FILES (Non-standard)"
find / -perm -4000 -type f 2>/dev/null | grep -v -E "^/(usr/(bin|sbin|lib)|bin|sbin)/" | head -20 || echo "  None found or insufficient permissions."

# ---- SSH Configuration ----
section "SSH CONFIGURATION"
if [ -f /etc/ssh/sshd_config ]; then
    grep -v "^#" /etc/ssh/sshd_config 2>/dev/null | grep -v "^$" | head -30
else
    echo "  /etc/ssh/sshd_config not found."
fi

section "END OF REPORT"

} > "$OUTFILE" 2>&1

echo "[Prismo] Report saved to: $OUTFILE"
