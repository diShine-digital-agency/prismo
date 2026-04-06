#!/usr/bin/env bash
#
# Prismo — AI Consulting Toolkit — Launcher Linux/macOS
# Configures the environment from the USB drive and launches the AI engine.
#
# Part of Prismo by diShine Digital Agency
# https://dishine.it | https://github.com/diShine-digital-agency/prismo
#

set -euo pipefail

# === AUTO-DETECT USB ROOT ===
USB_ROOT="$(cd "$(dirname "$0")" && pwd)"

# === READ VERSION ===
PRISMO_VERSION="unknown"
if [ -f "$USB_ROOT/VERSION" ]; then
    PRISMO_VERSION=$(cat "$USB_ROOT/VERSION" | tr -d '[:space:]')
fi

# === CHECKSUM VERIFICATION ===
if [ -f "$USB_ROOT/SHA256SUMS" ]; then
    if command -v sha256sum &>/dev/null; then
        if ! (cd "$USB_ROOT" && sha256sum -c SHA256SUMS --status 2>/dev/null); then
            echo -e "\033[0;31mWARNING: One or more scripts have been modified! The USB drive may have been tampered with.\033[0m"
            echo -n "Press Enter to continue or Ctrl+C to abort... "
            read -r _
        fi
    elif command -v shasum &>/dev/null; then
        if ! (cd "$USB_ROOT" && shasum -a 256 -c SHA256SUMS --status 2>/dev/null); then
            echo -e "\033[0;31mWARNING: One or more scripts have been modified! The USB drive may have been tampered with.\033[0m"
            echo -n "Press Enter to continue or Ctrl+C to abort... "
            read -r _
        fi
    fi
fi

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# === DETECT OS AND ARCHITECTURE ===
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

case "$OS_TYPE" in
    Linux)
        case "$ARCH" in
            x86_64)  NODE_DIR="$USB_ROOT/runtime/node-linux-x64" ;;
            aarch64) NODE_DIR="$USB_ROOT/runtime/node-linux-arm64" ;;
            *)
                echo -e "${RED}[ERROR] Unsupported architecture: $ARCH${NC}"
                exit 1
                ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            x86_64)  NODE_DIR="$USB_ROOT/runtime/node-darwin-x64" ;;
            arm64)   NODE_DIR="$USB_ROOT/runtime/node-darwin-arm64" ;;
            *)
                echo -e "${RED}[ERROR] Unsupported architecture: $ARCH${NC}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo -e "${RED}[ERROR] Unsupported OS: $OS_TYPE${NC}"
        exit 1
        ;;
esac

# === SETUP NODE.JS ===
# Always extract to /tmp/ because:
# 1. exFAT doesn't support symlinks (npm, npx, corepack are symlinks)
# 2. exFAT/USB may be mounted with noexec
# 3. Local disk is much faster than USB
LOCAL_NODE_DIR="/tmp/prismo-node-runtime"
LOCAL_NODE="$LOCAL_NODE_DIR/bin/node"

if [ ! -f "$LOCAL_NODE" ]; then
    TAR_FILE=$(find "$NODE_DIR" -name "*.tar.xz" -o -name "*.tar.gz" 2>/dev/null | head -1)

    if [ -f "$NODE_DIR/bin/node" ] && [ -z "$TAR_FILE" ]; then
        echo -e "${YELLOW}[*] Preparing runtime...${NC}"
        mkdir -p "$LOCAL_NODE_DIR/bin"
        cp "$NODE_DIR/bin/node" "$LOCAL_NODE"
        chmod +x "$LOCAL_NODE"
    elif [ -n "$TAR_FILE" ]; then
        if [[ "$TAR_FILE" == *.tar.xz ]] && ! command -v xz &>/dev/null; then
            echo -e "${YELLOW}[*] Installing xz-utils for Node.js extraction...${NC}"
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -qq && sudo apt-get install -y -qq xz-utils
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y -q xz
            elif command -v yum &>/dev/null; then
                sudo yum install -y -q xz
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm xz
            elif command -v apk &>/dev/null; then
                sudo apk add xz
            else
                echo -e "${RED}[ERROR] xz-utils not installed and package manager not recognized.${NC}"
                exit 1
            fi
        fi
        echo -e "${YELLOW}[*] Extracting Node.js locally...${NC}"
        mkdir -p "$LOCAL_NODE_DIR"
        tar -xf "$TAR_FILE" -C "$LOCAL_NODE_DIR" --strip-components=1
        chmod +x "$LOCAL_NODE" 2>/dev/null || true
        if [ -f "$LOCAL_NODE" ]; then
            echo -e "${GREEN}[OK] Node.js extracted.${NC}"
        else
            echo -e "${RED}[ERROR] Extraction failed.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}[ERROR] Node.js not found in $NODE_DIR${NC}"
        echo "Run setup-usb.ps1 on Windows to prepare the USB drive."
        exit 1
    fi
else
    echo -e "${GREEN}[OK] Node.js ready (cached locally).${NC}"
fi

if ! "$LOCAL_NODE" --version &>/dev/null; then
    echo -e "${RED}[ERROR] Node.js is not working. Check the version for this OS/arch.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Node.js $("$LOCAL_NODE" --version) ready.${NC}"

# === DETECT AI ENGINE STRUCTURE ===
ENGINE_DIR="$USB_ROOT/engine"
AI_BIN=""
CLI_JS=""
NODE_MODULES_DIR=""

if [ -f "$ENGINE_DIR/node_modules/@anthropic-ai/claude-code/cli.js" ]; then
    CLI_JS="$ENGINE_DIR/node_modules/@anthropic-ai/claude-code/cli.js"
    NODE_MODULES_DIR="$ENGINE_DIR/node_modules"
elif [ -f "$ENGINE_DIR/lib/node_modules/@anthropic-ai/claude-code/cli.js" ]; then
    CLI_JS="$ENGINE_DIR/lib/node_modules/@anthropic-ai/claude-code/cli.js"
    NODE_MODULES_DIR="$ENGINE_DIR/lib/node_modules"
fi

if [ -n "$CLI_JS" ]; then
    AI_BIN="/tmp/prismo-ai-wrapper"
    cat > "$AI_BIN" << WRAPPER
#!/bin/sh
exec "$LOCAL_NODE" "$CLI_JS" "\$@"
WRAPPER
    chmod +x "$AI_BIN"
    echo -e "${GREEN}[OK] AI engine configured.${NC}"
fi

# === SESSION LOGGING ===
mkdir -p "$USB_ROOT/toolkit/logs"
LOG_FILE="$USB_ROOT/toolkit/logs/session-$(date +%Y-%m-%d_%H%M%S).log"
{
    echo "=== Prismo Session Log ==="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "OS: $OS_TYPE $(uname -r)"
    echo "========================="
    echo ""
} > "$LOG_FILE"

run_ai() {
    "$AI_BIN" "$@" 2>&1 | tee -a "$LOG_FILE"
}

# === CONFIGURE ENVIRONMENT ===
export PATH="/tmp:$NODE_DIR/bin:$PATH"
export NPM_CONFIG_PREFIX="$ENGINE_DIR"
export CLAUDE_CONFIG_DIR="$USB_ROOT/config"
export NODE_PATH="${NODE_MODULES_DIR:-$ENGINE_DIR/node_modules}"

# === VERIFY AI ENGINE ===
if [ -z "$AI_BIN" ] || [ ! -f "$AI_BIN" ]; then
    echo -e "${RED}[ERROR] AI engine not found.${NC}"
    echo ""
    echo "Possible causes:"
    echo "  - USB drive not prepared (run setup-usb.ps1 on Windows)"
    echo "  - engine/ directory is incomplete"
    echo ""
    echo "Contents of engine/:"
    ls -la "$ENGINE_DIR/" 2>/dev/null || echo "  (directory not found)"
    exit 1
fi

# === LOAD CONFIG ===
CONFIG_FILE="$USB_ROOT/prismo.config.json"
CLIENT_NAME=""
if [ -f "$CONFIG_FILE" ] && command -v python3 &>/dev/null; then
    CLIENT_NAME=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('client',{}).get('name',''))" 2>/dev/null || echo "")
fi

# === DETECT SYSTEM ===
if [ "$OS_TYPE" = "Darwin" ]; then
    OS_NAME=$(sw_vers -productName 2>/dev/null || echo "macOS")
    OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    OS_NAME="$OS_NAME $OS_VERSION"
    KERNEL=$(uname -r)
    RAM_GB=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1073741824}' || echo "N/A")
else
    OS_NAME=$(cat /etc/os-release 2>/dev/null | grep "^PRETTY_NAME=" | cut -d'"' -f2 || uname -s)
    KERNEL=$(uname -r)
    RAM_GB=$(free -g 2>/dev/null | awk '/Mem:/{print $2}' || echo "N/A")
fi
HOSTNAME_VAL=$(hostname)

# === REPORT GENERATION ===
generate_report_header() {
    local report_file="$1"
    local report_title="$2"
    local client="${CLIENT_NAME:-Unknown Client}"
    mkdir -p "$USB_ROOT/toolkit/reports"
    cat > "$report_file" << HEADER
# $report_title

**Generated by Prismo** — AI Consulting Toolkit by diShine Digital Agency
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Client:** $client
**System:** $OS_NAME | $HOSTNAME_VAL | RAM: ${RAM_GB}GB

---

HEADER
}

# === LANGUAGE ===
set_language() {
    if [ "$1" = "en" ]; then
        # --- System Health ---
        M1=" [1]  System diagnosis"
        M2=" [2]  Log analysis"
        M3=" [3]  Network diagnostics"
        # --- Web & Performance ---
        M4=" [4]  Website performance audit"
        M5=" [5]  Tech stack analysis"
        M6=" [6]  Accessibility audit (WCAG 2.1)"
        # --- SEO ---
        M7=" [7]  Technical SEO audit"
        M8=" [8]  On-page SEO analysis"
        M9=" [9]  Competitive SEO snapshot"
        # --- MarTech & Data ---
        M10="[10]  MarTech stack audit"
        M11="[11]  Data quality check"
        # --- Security ---
        M12="[12]  Website security scan"
        M13="[13]  System security audit"
        # --- Utilities ---
        M14="[14]  Interactive AI session"
        M15="[15]  Remote SSH diagnostics"
        M0=" [0]  Safe eject USB"
        MQ=" [Q]  Quit"
        MSG_CHOICE="Choice: "
        MSG_URL="Website URL: "
        MSG_URLS="Competitor URLs (comma-separated): "
        MSG_LOGPATH="Log file path: "
        MSG_PROBLEM="Describe the problem: "
        MSG_SSHHOST="Host (user@ip): "
        MSG_DIAGSTART="[*] Starting diagnosis..."
        MSG_BYE="Goodbye. No traces left on the system."
        MSG_EJECT_SYNC="Flushing buffers..."
        MSG_EJECT_OK="USB safely ejected. You can remove the drive now."
        MSG_EJECT_FAIL="Could not eject the USB drive. Close all open files and try again."
        MSG_INVALID="Invalid choice."
        MSG_NOTFOUND="[ERROR] File not found:"
        MSG_SAVED="[OK] Report saved to"
        SECTION_SYS="System Health"
        SECTION_WEB="Web & Performance"
        SECTION_SEO="SEO"
        SECTION_MAR="MarTech & Data"
        SECTION_SEC="Security"
        SECTION_UTL="Utilities"
    elif [ "$1" = "fr" ]; then
        # --- System Health ---
        M1=" [1]  Diagnostic systeme"
        M2=" [2]  Analyse de logs"
        M3=" [3]  Diagnostic reseau"
        # --- Web & Performance ---
        M4=" [4]  Audit performance web"
        M5=" [5]  Analyse stack technique"
        M6=" [6]  Audit accessibilite (WCAG 2.1)"
        # --- SEO ---
        M7=" [7]  Audit SEO technique"
        M8=" [8]  Analyse SEO on-page"
        M9=" [9]  Snapshot SEO concurrentiel"
        # --- MarTech & Data ---
        M10="[10]  Audit stack MarTech"
        M11="[11]  Controle qualite des donnees"
        # --- Security ---
        M12="[12]  Scan securite site web"
        M13="[13]  Audit securite systeme"
        # --- Utilities ---
        M14="[14]  Session AI interactive"
        M15="[15]  Diagnostic SSH distant"
        M0=" [0]  Ejecter la cle USB"
        MQ=" [Q]  Quitter"
        MSG_CHOICE="Choix : "
        MSG_URL="URL du site web : "
        MSG_URLS="URL concurrents (separes par des virgules) : "
        MSG_LOGPATH="Chemin du fichier log : "
        MSG_PROBLEM="Decrivez le probleme : "
        MSG_SSHHOST="Hote (user@ip) : "
        MSG_DIAGSTART="[*] Demarrage du diagnostic..."
        MSG_BYE="Au revoir. Aucune trace laissee sur le systeme."
        MSG_EJECT_SYNC="Vidange des tampons..."
        MSG_EJECT_OK="Cle USB ejectee en securite. Vous pouvez la retirer."
        MSG_EJECT_FAIL="Impossible d'ejecter la cle USB. Fermez tous les fichiers et reessayez."
        MSG_INVALID="Choix invalide."
        MSG_NOTFOUND="[ERREUR] Fichier introuvable :"
        MSG_SAVED="[OK] Rapport sauvegarde dans"
        SECTION_SYS="Sante systeme"
        SECTION_WEB="Web & Performance"
        SECTION_SEO="SEO"
        SECTION_MAR="MarTech & Donnees"
        SECTION_SEC="Securite"
        SECTION_UTL="Utilitaires"
    else
        # --- System Health ---
        M1=" [1]  Diagnosi sistema"
        M2=" [2]  Analisi log"
        M3=" [3]  Diagnosi rete"
        # --- Web & Performance ---
        M4=" [4]  Audit performance sito web"
        M5=" [5]  Analisi tech stack"
        M6=" [6]  Audit accessibilita' (WCAG 2.1)"
        # --- SEO ---
        M7=" [7]  Audit SEO tecnico"
        M8=" [8]  Analisi SEO on-page"
        M9=" [9]  Snapshot SEO competitivo"
        # --- MarTech & Data ---
        M10="[10]  Audit stack MarTech"
        M11="[11]  Controllo qualita' dati"
        # --- Security ---
        M12="[12]  Scansione sicurezza sito web"
        M13="[13]  Audit sicurezza sistema"
        # --- Utilities ---
        M14="[14]  Sessione AI interattiva"
        M15="[15]  Diagnostica remota SSH"
        M0=" [0]  Sgancia chiavetta USB"
        MQ=" [Q]  Esci"
        MSG_CHOICE="Scelta: "
        MSG_URL="URL del sito web: "
        MSG_URLS="URL competitor (separati da virgola): "
        MSG_LOGPATH="Percorso file di log: "
        MSG_PROBLEM="Descrivi il problema: "
        MSG_SSHHOST="Host (user@ip): "
        MSG_DIAGSTART="[*] Avvio diagnosi..."
        MSG_BYE="Arrivederci. Nessuna traccia lasciata sul sistema."
        MSG_EJECT_SYNC="Scaricamento buffer in corso..."
        MSG_EJECT_OK="Chiavetta USB sganciata in sicurezza. Puoi rimuoverla."
        MSG_EJECT_FAIL="Impossibile sganciare la chiavetta. Chiudi tutti i file aperti e riprova."
        MSG_INVALID="Scelta non valida."
        MSG_NOTFOUND="[ERRORE] File non trovato:"
        MSG_SAVED="[OK] Report salvato in"
        SECTION_SYS="Sistema"
        SECTION_WEB="Web & Performance"
        SECTION_SEO="SEO"
        SECTION_MAR="MarTech & Dati"
        SECTION_SEC="Sicurezza"
        SECTION_UTL="Utilita'"
    fi
}

# Default Italian
set_language "it"

# === BANNER ===
show_banner() {
    echo ""
    echo -e "${CYAN}  ================================================${NC}"
    echo -e "${CYAN}   ____  ____  ___ ____  __  __  ___${NC}"
    echo -e "${CYAN}  |  _ \\|  _ \\|_ _/ ___||  \\/  |/ _ \\ ${NC}"
    echo -e "${CYAN}  | |_) | |_) || |\\___ \\| |\\/| | | | |${NC}"
    echo -e "${CYAN}  |  __/|  _ < | | ___) | |  | | |_| |${NC}"
    echo -e "${CYAN}  |_|   |_| \\_\\___|____/|_|  |_|\\___/${NC}"
    echo ""
    echo -e "${CYAN}    >_ AI Consulting Toolkit${NC}"
    echo -e "${CYAN}       by diShine Digital Agency${NC}"
    echo ""
    echo -e "${DARKGRAY}    v${PRISMO_VERSION}${NC}"
    echo -e "${CYAN}    Portable — no installation required${NC}"
    echo -e "${CYAN}  ================================================${NC}"
    echo ""
    echo -e "${GRAY}  System: $OS_NAME${NC}"
    echo -e "${GRAY}  Kernel: $KERNEL${NC}"
    echo -e "${GRAY}  RAM:    ${RAM_GB} GB${NC}"
    echo -e "${GRAY}  Host:   $HOSTNAME_VAL${NC}"
    if [ -n "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}  Client: $CLIENT_NAME${NC}"
    fi
    echo ""
    echo -e "  ${CYAN}[I]${NC} Italiano  ${CYAN}[E]${NC} English  ${CYAN}[F]${NC} Francais"
    echo ""
    echo -n "  Language / Lingua: "
    read -r lang_choice
    case "$lang_choice" in
        E|e) set_language "en" ;;
        F|f) set_language "fr" ;;
        *) set_language "it" ;;
    esac
    echo ""
}

# === MENU ===
show_menu() {
    echo ""
    echo -e "${CYAN}  ┌─────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_SYS ──${NC}                           ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M1"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M2"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M3"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_WEB ──${NC}                      ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M4"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M5"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M6"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_SEO ──${NC}                              ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M7"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M8"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M9"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_MAR ──${NC}                       ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M10"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M11"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_SEC ──${NC}                          ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M12"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M13"
    echo -e "${CYAN}  │${NC}  ${GREEN}── $SECTION_UTL ──${NC}                          ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M14"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M15"
    echo -e "${CYAN}  │${NC}                                             ${CYAN}│${NC}"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$M0"
    printf "${CYAN}  │${NC}  %-41s${CYAN}│${NC}\n" "$MQ"
    echo -e "${CYAN}  └─────────────────────────────────────────────┘${NC}"
}

# === PROMPT LOADER ===
load_prompt() {
    local prompt_file="$USB_ROOT/toolkit/prompts/$1"
    if [ -f "$prompt_file" ]; then
        cat "$prompt_file"
    else
        echo ""
    fi
}

# === FUNCTIONS ===

# --- System Health ---
do_system_diagnosis() {
    echo -e "${GREEN}${MSG_DIAGSTART}${NC}"
    local prompt_file
    if [ "$OS_TYPE" = "Darwin" ]; then
        prompt_file="system/macos-health.md"
    else
        prompt_file="system/linux-health.md"
    fi
    local base_prompt
    base_prompt=$(load_prompt "$prompt_file")
    local sys_context="Current system: OS=$OS_NAME, Kernel=$KERNEL, RAM=${RAM_GB}GB, Host=$HOSTNAME_VAL"
    run_ai -p "$base_prompt

$sys_context"
}

do_log_analysis() {
    echo -n "$MSG_LOGPATH"
    read -r log_path
    if [ ! -f "$log_path" ]; then
        echo -e "${RED}${MSG_NOTFOUND} $log_path${NC}"
        return
    fi
    run_ai -p "Analyze the log file '$log_path'. Identify errors, warnings, and anomalous patterns. Provide a structured summary and suggest solutions."
}

do_network_diagnosis() {
    echo -e "${GREEN}${MSG_DIAGSTART}${NC}"
    if [ "$OS_TYPE" = "Darwin" ]; then
        run_ai -p "Complete macOS network diagnosis: interfaces (ifconfig), IP config, DNS (scutil --dns), routing (netstat -rn), listening ports (lsof -i -P), active connections, firewall (socketfilterfw), connectivity test. Identify problems and propose fixes."
    else
        run_ai -p "Complete Linux network diagnosis: interfaces, IP, DNS, routing, listening ports (ss/netstat), active connections, firewall (iptables/nftables/firewalld), connectivity test. Identify problems and propose fixes."
    fi
}

# --- Web & Performance ---
do_website_performance() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "web/website-performance.md")
    run_ai -p "$prompt

Target URL: $site_url
System has Lighthouse CLI and pa11y available in PATH.
Generate the report in Markdown format."
}

do_tech_stack() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "web/tech-stack-analysis.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

do_accessibility_audit() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "web/accessibility-audit.md")
    run_ai -p "$prompt

Target URL: $site_url
System has pa11y available in PATH for automated testing."
}

# --- SEO ---
do_seo_technical() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "seo/seo-technical.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

do_seo_onpage() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "seo/seo-onpage.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

do_seo_competitive() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    echo -n "$MSG_URLS"
    read -r competitor_urls
    local prompt
    prompt=$(load_prompt "seo/seo-competitive.md")
    run_ai -p "$prompt

Client URL: $site_url
Competitor URLs: $competitor_urls"
}

# --- MarTech & Data ---
do_martech_audit() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "martech/martech-stack-audit.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

do_data_quality() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "martech/martech-data-quality.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

# --- Security ---
do_website_security() {
    echo -n "$MSG_URL"
    read -r site_url
    [ -z "$site_url" ] && return
    local prompt
    prompt=$(load_prompt "security/website-security.md")
    run_ai -p "$prompt

Target URL: $site_url"
}

do_system_security() {
    echo -e "${GREEN}${MSG_DIAGSTART}${NC}"
    if [ "$OS_TYPE" = "Darwin" ]; then
        run_ai -p "Run a COMPLETE and AUTONOMOUS macOS security analysis without asking for confirmation. Check: users/groups (dscl), FileVault status, Gatekeeper, SIP (csrutil), firewall, SSH config, open ports, installed profiles, suspicious launch agents/daemons, Keychain issues, software updates, remote login, screen sharing, AirDrop settings. Do NOT ask for confirmation, do NOT stop between checks. Produce a structured report with severity (CRITICAL/HIGH/MEDIUM/LOW) and remediation for each issue found."
    else
        run_ai -p "Run a COMPLETE and AUTONOMOUS Linux security analysis without asking for confirmation. Check: users/groups, sudoers, SUID/SGID, open ports, exposed services, SSH config, fail2ban, security updates, sensitive file permissions (/etc/shadow, /etc/passwd), suspicious crontabs, anomalous processes, SELinux/AppArmor, authorized SSH keys. Do NOT ask for confirmation. Produce a structured report with severity (CRITICAL/HIGH/MEDIUM/LOW) and remediation for each issue."
    fi
}

# --- Utilities ---
do_ssh_remote() {
    echo -n "$MSG_SSHHOST"
    read -r ssh_host
    run_ai "Connect via SSH to $ssh_host. Diagnose: OS, services, disk, memory, error logs. For each problem propose fix and ask confirmation."
}

do_eject_usb() {
    local mount_point device
    mount_point=$(df "$USB_ROOT" 2>/dev/null | tail -1 | awk '{print $NF}')
    device=$(df "$USB_ROOT" 2>/dev/null | tail -1 | awk '{print $1}')

    echo -e "${CYAN}${MSG_EJECT_SYNC}${NC}"
    sync

    # Clean temp files
    rm -rf /tmp/prismo-node-runtime /tmp/prismo-ai-wrapper 2>/dev/null

    local eject_script="/tmp/prismo-eject.sh"
    cat > "$eject_script" << 'EOFHEADER'
#!/usr/bin/env bash
cd /

EJECT_OS="$1"
EJECT_DEVICE="$2"
EJECT_MOUNT="$3"
EJECT_MSG_OK="$4"
EJECT_MSG_FAIL="$5"

sleep 2
eject_ok=false

if [ "$EJECT_OS" = "Darwin" ]; then
    if diskutil unmount force "$EJECT_MOUNT" 2>/dev/null; then
        disk_id=$(echo "$EJECT_DEVICE" | sed 's/s[0-9]*$//')
        diskutil eject "$disk_id" 2>/dev/null || true
        eject_ok=true
    fi
else
    parent_dev=$(echo "$EJECT_DEVICE" | sed 's/[0-9]*$//')
    fuser -km "$EJECT_MOUNT" 2>/dev/null || true
    sleep 1

    if command -v udisksctl &>/dev/null; then
        if udisksctl unmount -b "$EJECT_DEVICE" 2>/dev/null; then
            udisksctl power-off -b "$parent_dev" 2>/dev/null || true
            eject_ok=true
        fi
    fi

    if [ "$eject_ok" = "false" ] && command -v gio &>/dev/null; then
        gio mount -u "$EJECT_MOUNT" 2>/dev/null && eject_ok=true
    fi

    if [ "$eject_ok" = "false" ]; then
        sudo -n umount -l "$EJECT_MOUNT" 2>/dev/null && eject_ok=true
    fi
    if [ "$eject_ok" = "false" ]; then
        umount -l "$EJECT_MOUNT" 2>/dev/null && eject_ok=true
    fi
fi

if [ "$eject_ok" = "true" ]; then
    echo ""
    echo "$EJECT_MSG_OK"
else
    echo ""
    echo "$EJECT_MSG_FAIL"
fi

sleep 2
rm -f "$0"
EOFHEADER

    chmod +x "$eject_script"
    nohup bash "$eject_script" "$OS_TYPE" "$device" "$mount_point" "$MSG_EJECT_OK" "$MSG_EJECT_FAIL" >/dev/null 2>&1 &
    exit 0
}

# === MAIN ===
show_banner

while true; do
    show_menu
    echo ""
    echo -n "  $MSG_CHOICE"
    read -r choice
    echo ""

    case "$choice" in
        1)  do_system_diagnosis ;;
        2)  do_log_analysis ;;
        3)  do_network_diagnosis ;;
        4)  do_website_performance ;;
        5)  do_tech_stack ;;
        6)  do_accessibility_audit ;;
        7)  do_seo_technical ;;
        8)  do_seo_onpage ;;
        9)  do_seo_competitive ;;
        10) do_martech_audit ;;
        11) do_data_quality ;;
        12) do_website_security ;;
        13) do_system_security ;;
        14) echo "[$(date)] Interactive session started" >> "$LOG_FILE"; "$AI_BIN" ; echo "[$(date)] Interactive session ended" >> "$LOG_FILE" ;;
        15) do_ssh_remote ;;
        0)  do_eject_usb ;;
        q|Q)
            echo -e "${GREEN}${MSG_BYE}${NC}"
            exit 0
            ;;
        *) echo -e "${RED}${MSG_INVALID}${NC}" ;;
    esac
    echo ""
done
