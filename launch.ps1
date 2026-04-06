<#
.SYNOPSIS
    Prismo - AI Consulting Toolkit - PowerShell Launcher for Windows.
    Configures the portable environment and launches the AI engine from USB.

.DESCRIPTION
    Part of Prismo by diShine Digital Agency.
    https://dishine.it | https://github.com/diShine-digital-agency/prismo

    Sets up PATH, Node.js, AI engine, and Git Portable from the USB drive.
    Presents a bilingual (IT/EN) 15-option consulting menu organised by domain.
    Logs every session to toolkit\logs\.

.PARAMETER Modalita
    Launch a specific mode directly, bypassing the interactive menu.
    Valid values: diagnosi, log, rete, webperf, techstack, accessibility,
                  seotecnico, seoonpage, seocompetitivo, martech, dataquality,
                  websecurity, syssecurity, interattivo, ssh, menu

.EXAMPLE
    .\launch.ps1
    .\launch.ps1 -Modalita interattivo
#>

param(
    [ValidateSet(
        "diagnosi","log","rete",
        "webperf","techstack","accessibility",
        "seotecnico","seoonpage","seocompetitivo",
        "martech","dataquality",
        "websecurity","syssecurity",
        "interattivo","ssh","menu"
    )]
    [string]$Modalita = "menu"
)

$ErrorActionPreference = "Continue"
$UsbRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Read version from VERSION file
$PrismoVersion = "unknown"
$versionFile = Join-Path $UsbRoot "VERSION"
if (Test-Path $versionFile) {
    $PrismoVersion = (Get-Content $versionFile -Raw).Trim()
}

# ======================================================================
# ENVIRONMENT SETUP
# ======================================================================
$env:PATH = "$UsbRoot\runtime\node-win-x64;$UsbRoot\engine\bin;$env:PATH"
$env:NPM_CONFIG_PREFIX = "$UsbRoot\engine"
$env:CLAUDE_CONFIG_DIR = "$UsbRoot\config"
$env:NODE_PATH = "$UsbRoot\engine\lib\node_modules"

# Detect Git Portable
$gitDir = Join-Path $UsbRoot "runtime\git-win-x64"
$gitBash = Join-Path $gitDir "bin\bash.exe"
if (Test-Path $gitBash) {
    $env:CLAUDE_CODE_GIT_BASH_PATH = $gitBash
    $env:PATH = "$gitDir\bin;$gitDir\cmd;$env:PATH"
}

$engineBin = Join-Path $UsbRoot "engine\bin\claude.cmd"
$nodeBin  = Join-Path $UsbRoot "runtime\node-win-x64\node.exe"

# Detect AI engine via cli.js fallback
$cliJsPath = ""
$nodeModulesDir = ""
if (Test-Path (Join-Path $UsbRoot "engine\node_modules\@anthropic-ai\claude-code\cli.js")) {
    $cliJsPath = Join-Path $UsbRoot "engine\node_modules\@anthropic-ai\claude-code\cli.js"
    $nodeModulesDir = Join-Path $UsbRoot "engine\node_modules"
} elseif (Test-Path (Join-Path $UsbRoot "engine\lib\node_modules\@anthropic-ai\claude-code\cli.js")) {
    $cliJsPath = Join-Path $UsbRoot "engine\lib\node_modules\@anthropic-ai\claude-code\cli.js"
    $nodeModulesDir = Join-Path $UsbRoot "engine\lib\node_modules"
}

if ($nodeModulesDir) {
    $env:NODE_PATH = $nodeModulesDir
}

# ======================================================================
# VALIDATION
# ======================================================================
if (-not (Test-Path $nodeBin)) {
    Write-Host "[ERROR] Node.js not found. Run setup-usb.ps1 first." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $engineBin)) {
    if ($cliJsPath) {
        # Create a wrapper cmd
        $wrapperContent = "@echo off`r`n`"$nodeBin`" `"$cliJsPath`" %*"
        $wrapperDir = Split-Path $engineBin
        if (-not (Test-Path $wrapperDir)) { New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null }
        Set-Content -Path $engineBin -Value $wrapperContent -Encoding ASCII
        Write-Host "[OK] ai-engine.cmd generated from cli.js" -ForegroundColor Green
    } else {
        Write-Host "[*] claude.cmd not found, attempting auto-repair..." -ForegroundColor Yellow
        $tempFiles = Get-ChildItem (Join-Path $UsbRoot "engine") -Filter ".claude.cmd-*" -ErrorAction SilentlyContinue
        if ($tempFiles) {
            Copy-Item $tempFiles[0].FullName $engineBin -Force
            Write-Host "[OK] claude.cmd restored from $($tempFiles[0].Name)" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] AI engine not found. Run setup-usb.ps1 first." -ForegroundColor Red
            exit 1
        }
    }
}

# ======================================================================
# CHECKSUM VERIFICATION
# ======================================================================
$sha256File = Join-Path $UsbRoot "SHA256SUMS"
if (Test-Path $sha256File) {
    $checksumFail = $false
    Get-Content $sha256File | ForEach-Object {
        $parts = $_ -split "\s+", 2
        if ($parts.Count -eq 2) {
            $expectedHash = $parts[0].Trim()
            $filePath = Join-Path $UsbRoot $parts[1].Trim()
            if (Test-Path $filePath) {
                $actualHash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash.ToLower()
                if ($actualHash -ne $expectedHash.ToLower()) {
                    $checksumFail = $true
                }
            }
        }
    }
    if ($checksumFail) {
        Write-Host "WARNING: One or more scripts have been modified! The USB drive may have been tampered with." -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to continue or Ctrl+C to abort"
    }
}

# ======================================================================
# DETECT SYSTEM
# ======================================================================
$osInfo  = Get-CimInstance Win32_OperatingSystem
$cpuInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
$ramGB   = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)

# ======================================================================
# SESSION LOGGING
# ======================================================================
$logDir = Join-Path $UsbRoot "toolkit\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$logFile = Join-Path $logDir "session-$timestamp.log"

@"
=== Prismo Session Log ===
Date: $(Get-Date)
Hostname: $($env:COMPUTERNAME)
OS: $($osInfo.Caption)
Version: $($osInfo.Version)
RAM: ${ramGB} GB
==========================

"@ | Out-File -FilePath $logFile -Encoding UTF8

function Write-Log {
    param([string]$Message)
    "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# ======================================================================
# LOAD CONFIG
# ======================================================================
$configFile = Join-Path $UsbRoot "prismo.config.json"
$clientName = ""
if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile -Raw | ConvertFrom-Json
        $clientName = $config.client.name
    } catch {}
}

# ======================================================================
# PROMPT LOADER
# ======================================================================
function Get-PromptContent {
    param([string]$RelativePath)
    $promptFile = Join-Path $UsbRoot "toolkit\prompts\$RelativePath"
    if (Test-Path $promptFile) {
        return Get-Content $promptFile -Raw
    }
    return ""
}

# ======================================================================
# AI ENGINE INVOCATION
# ======================================================================
function Invoke-Engine {
    param([string]$Prompt)
    Write-Log "AI engine invoked with prompt (first 80 chars): $($Prompt.Substring(0, [Math]::Min(80, $Prompt.Length)))..."
    & $engineBin -p $Prompt
    Write-Log "AI engine invocation completed."
}

function Invoke-EngineInteractive {
    Write-Log "Interactive session started."
    & $engineBin
    Write-Log "Interactive session ended."
}

# ======================================================================
# REPORT GENERATION
# ======================================================================
function New-ReportHeader {
    param([string]$ReportFile, [string]$Title)
    $client = if ($clientName) { $clientName } else { "Unknown Client" }
    $reportDir = Join-Path $UsbRoot "toolkit\reports"
    if (-not (Test-Path $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
    @"
# $Title

**Generated by Prismo** -- AI Consulting Toolkit by diShine Digital Agency
**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Client:** $client
**System:** $($osInfo.Caption) | $($env:COMPUTERNAME) | RAM: ${ramGB}GB

---

"@ | Out-File -FilePath $ReportFile -Encoding UTF8
}

# ======================================================================
# LANGUAGE STRINGS
# ======================================================================
$strings = @{}

function Set-Language {
    param([string]$Lang)
    if ($Lang -eq "en") {
        $script:strings = @{
            # Section headers
            SectionSys = "System Health"
            SectionWeb = "Web & Performance"
            SectionSeo = "SEO"
            SectionMar = "MarTech & Data"
            SectionSec = "Security"
            SectionUtl = "Utilities"
            # Menu items
            M1  = " [1]  System diagnosis"
            M2  = " [2]  Log analysis"
            M3  = " [3]  Network diagnosis"
            M4  = " [4]  Website performance audit"
            M5  = " [5]  Tech stack analysis"
            M6  = " [6]  Accessibility audit (WCAG 2.1)"
            M7  = " [7]  Technical SEO audit"
            M8  = " [8]  On-page SEO analysis"
            M9  = " [9]  Competitive SEO snapshot"
            M10 = "[10]  MarTech stack audit"
            M11 = "[11]  Data quality check"
            M12 = "[12]  Website security scan"
            M13 = "[13]  System security audit"
            M14 = "[14]  Interactive AI session"
            M15 = "[15]  Remote SSH diagnostics"
            M0  = " [0]  Safe eject USB"
            MQ  = " [Q]  Quit"
            # Messages
            Choice    = "Choice"
            Url       = "Website URL"
            Urls      = "Competitor URLs (comma-separated)"
            LogPath   = "Log file path"
            Problem   = "Describe the problem"
            SshHost   = "Host (user@ip)"
            DiagStart = "[*] Starting diagnosis..."
            Bye       = "Goodbye. No traces left on the system."
            EjectSync = "Flushing buffers..."
            EjectOk   = "USB safely ejected. You can remove the drive now."
            EjectFail = "Could not eject the USB drive. Close all open files and try again."
            Invalid   = "Invalid choice."
            NotFound  = "[ERROR] File not found:"
            Saved     = "[OK] Report saved to"
            Back      = "Back to menu."
        }
    } else {
        $script:strings = @{
            # Section headers
            SectionSys = "Sistema"
            SectionWeb = "Web & Performance"
            SectionSeo = "SEO"
            SectionMar = "MarTech & Dati"
            SectionSec = "Sicurezza"
            SectionUtl = "Utilita'"
            # Menu items
            M1  = " [1]  Diagnosi sistema"
            M2  = " [2]  Analisi log"
            M3  = " [3]  Diagnosi rete"
            M4  = " [4]  Audit performance sito web"
            M5  = " [5]  Analisi tech stack"
            M6  = " [6]  Audit accessibilita' (WCAG 2.1)"
            M7  = " [7]  Audit SEO tecnico"
            M8  = " [8]  Analisi SEO on-page"
            M9  = " [9]  Snapshot SEO competitivo"
            M10 = "[10]  Audit stack MarTech"
            M11 = "[11]  Controllo qualita' dati"
            M12 = "[12]  Scansione sicurezza sito web"
            M13 = "[13]  Audit sicurezza sistema"
            M14 = "[14]  Sessione AI interattiva"
            M15 = "[15]  Diagnostica remota SSH"
            M0  = " [0]  Sgancia chiavetta USB"
            MQ  = " [Q]  Esci"
            # Messages
            Choice    = "Scelta"
            Url       = "URL del sito web"
            Urls      = "URL competitor (separati da virgola)"
            LogPath   = "Percorso file di log"
            Problem   = "Descrivi il problema"
            SshHost   = "Host (user@ip)"
            DiagStart = "[*] Avvio diagnosi..."
            Bye       = "Arrivederci. Nessuna traccia lasciata sul sistema."
            EjectSync = "Scaricamento buffer in corso..."
            EjectOk   = "Chiavetta USB sganciata in sicurezza. Puoi rimuoverla."
            EjectFail = "Impossibile sganciare la chiavetta. Chiudi tutti i file aperti e riprova."
            Invalid   = "Scelta non valida."
            NotFound  = "[ERRORE] File non trovato:"
            Saved     = "[OK] Report salvato in"
            Back      = "Torna al menu."
        }
    }
}

# ======================================================================
# BANNER
# ======================================================================
function Show-Banner {
    Write-Host ""
    Write-Host "  ================================================" -ForegroundColor Cyan
    Write-Host "   ____  ____  ___ ____  __  __  ___"              -ForegroundColor Cyan
    Write-Host "  |  _ \|  _ \|_ _/ ___||  \/  |/ _ \ "           -ForegroundColor Cyan
    Write-Host "  | |_) | |_) || |\___ \| |\/| | | | |"           -ForegroundColor Cyan
    Write-Host "  |  __/|  _ < | | ___) | |  | | |_| |"           -ForegroundColor Cyan
    Write-Host "  |_|   |_| \_\___|____/|_|  |_|\___/"             -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    >_ AI Consulting Toolkit"                      -ForegroundColor Cyan
    Write-Host "       by diShine Digital Agency"                  -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    v$PrismoVersion"                                    -ForegroundColor DarkGray
    Write-Host "    Portable - no installation required"           -ForegroundColor Cyan
    Write-Host "  ================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  System:  $($osInfo.Caption)"                     -ForegroundColor Gray
    Write-Host "  CPU:     $($cpuInfo.Name)"                       -ForegroundColor Gray
    Write-Host "  RAM:     ${ramGB} GB"                             -ForegroundColor Gray
    Write-Host "  Host:    $($env:COMPUTERNAME)"                   -ForegroundColor Gray
    if ($clientName) {
        Write-Host "  Client:  $clientName"                        -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  [I] Italiano  [E] English"                       -ForegroundColor White
    Write-Host ""
    $langChoice = Read-Host "  Language / Lingua"
    if ($langChoice -eq "E" -or $langChoice -eq "e") {
        Set-Language "en"
    } else {
        Set-Language "it"
    }
    Write-Host ""
}

# ======================================================================
# MENU
# ======================================================================
function Show-Menu {
    $pad = 41
    Write-Host ""
    Write-Host "  +-----------------------------------------------+" -ForegroundColor Cyan
    # System Health
    Write-Host ("  |  " + ("-- $($strings.SectionSys) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M1.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M2.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M3.PadRight($pad)  + "|") -ForegroundColor Cyan
    # Web & Performance
    Write-Host ("  |  " + ("-- $($strings.SectionWeb) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M4.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M5.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M6.PadRight($pad)  + "|") -ForegroundColor Cyan
    # SEO
    Write-Host ("  |  " + ("-- $($strings.SectionSeo) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M7.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M8.PadRight($pad)  + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M9.PadRight($pad)  + "|") -ForegroundColor Cyan
    # MarTech & Data
    Write-Host ("  |  " + ("-- $($strings.SectionMar) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M10.PadRight($pad) + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M11.PadRight($pad) + "|") -ForegroundColor Cyan
    # Security
    Write-Host ("  |  " + ("-- $($strings.SectionSec) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M12.PadRight($pad) + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M13.PadRight($pad) + "|") -ForegroundColor Cyan
    # Utilities
    Write-Host ("  |  " + ("-- $($strings.SectionUtl) --").PadRight($pad) + "|") -ForegroundColor Green
    Write-Host ("  |  " + $strings.M14.PadRight($pad) + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M15.PadRight($pad) + "|") -ForegroundColor Cyan
    Write-Host ("  |  " + "".PadRight($pad) + "|")            -ForegroundColor Cyan
    Write-Host ("  |  " + $strings.M0.PadRight($pad)  + "|") -ForegroundColor DarkGray
    Write-Host ("  |  " + $strings.MQ.PadRight($pad)  + "|") -ForegroundColor DarkGray
    Write-Host "  +-----------------------------------------------+" -ForegroundColor Cyan
}

# ======================================================================
# TASK FUNCTIONS
# ======================================================================

# --- System Health ---
function Start-SystemDiagnosis {
    Write-Host $strings.DiagStart -ForegroundColor Green
    Write-Log "Task: System Diagnosis"
    $basePrompt = Get-PromptContent "system\windows-health.md"
    $sysContext = "Current system: OS=$($osInfo.Caption), Version=$($osInfo.Version), RAM=${ramGB}GB, Host=$($env:COMPUTERNAME), CPU=$($cpuInfo.Name)"
    $prompt = @"
$basePrompt

$sysContext

Run a COMPLETE and AUTONOMOUS Windows system diagnosis without asking for confirmation.
Check: services (critical), disk space on all volumes, RAM/CPU usage, Event Log errors (last 24h),
network interfaces/DNS/gateway, pending Windows updates, antivirus/firewall status, failed scheduled tasks.
For each problem found: explain impact, severity (CRITICAL/HIGH/MEDIUM/LOW), and propose remediation.
Do NOT ask for confirmation between checks. Produce a structured report.
"@
    Invoke-Engine $prompt
}

function Start-LogAnalysis {
    $logPath = Read-Host $strings.LogPath
    if (-not $logPath -or -not (Test-Path $logPath)) {
        Write-Host "$($strings.NotFound) $logPath" -ForegroundColor Red
        return
    }
    Write-Log "Task: Log Analysis - $logPath"
    $basePrompt = Get-PromptContent "system\log-analysis.md"
    Invoke-Engine "$basePrompt`n`nAnalyze the log file '$logPath'. Identify errors, warnings, and anomalous patterns. Provide a structured summary with severity and suggest solutions."
}

function Start-NetworkDiagnosis {
    Write-Host $strings.DiagStart -ForegroundColor Green
    Write-Log "Task: Network Diagnosis"
    $basePrompt = Get-PromptContent "system\network-diagnosis.md"
    Invoke-Engine "$basePrompt`n`nRun a complete Windows network diagnosis: interfaces, IP config, DNS, gateway, routing table, listening ports, active connections, firewall rules, internet/DNS connectivity test. Identify problems and propose fixes."
}

# --- Web & Performance ---
function Start-WebsitePerformance {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Website Performance - $siteUrl"
    $basePrompt = Get-PromptContent "web\website-performance.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nGenerate the report in Markdown format. Analyze Core Web Vitals, loading performance, render-blocking resources, image optimization, caching headers, compression, and overall page weight."
}

function Start-TechStack {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Tech Stack Analysis - $siteUrl"
    $basePrompt = Get-PromptContent "web\tech-stack-analysis.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nIdentify the technology stack: CMS, frameworks, JavaScript libraries, analytics tools, CDN, hosting provider, server software, tag managers, and third-party integrations."
}

function Start-AccessibilityAudit {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Accessibility Audit - $siteUrl"
    $basePrompt = Get-PromptContent "web\accessibility-audit.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nPerform a WCAG 2.1 AA accessibility audit. Check: semantic HTML, ARIA attributes, color contrast, keyboard navigation, alt text, form labels, focus management, skip links, responsive design, screen reader compatibility."
}

# --- SEO ---
function Start-SeoTechnical {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Technical SEO Audit - $siteUrl"
    $basePrompt = Get-PromptContent "seo\seo-technical.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nPerform a technical SEO audit: robots.txt, sitemap.xml, canonical tags, hreflang, structured data/schema, page speed, mobile-friendliness, crawlability, indexation, redirect chains, HTTP status codes, SSL certificate."
}

function Start-SeoOnpage {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: On-page SEO Analysis - $siteUrl"
    $basePrompt = Get-PromptContent "seo\seo-onpage.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nPerform an on-page SEO analysis: title tags, meta descriptions, heading hierarchy (H1-H6), content quality, keyword density, internal linking, image optimization, URL structure, content freshness, E-E-A-T signals."
}

function Start-SeoCompetitive {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    $competitorUrls = Read-Host $strings.Urls
    Write-Log "Task: Competitive SEO Snapshot - $siteUrl vs $competitorUrls"
    $basePrompt = Get-PromptContent "seo\seo-competitive.md"
    Invoke-Engine "$basePrompt`n`nClient URL: $siteUrl`nCompetitor URLs: $competitorUrls`nCompare SEO positioning: domain authority signals, content strategy, keyword overlap, backlink profile indicators, technical SEO maturity, SERP feature usage."
}

# --- MarTech & Data ---
function Start-MartechAudit {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: MarTech Stack Audit - $siteUrl"
    $basePrompt = Get-PromptContent "martech\martech-stack-audit.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nAudit the MarTech stack: tag managers, analytics (GA4, etc.), CRM integrations, marketing automation, A/B testing tools, heatmaps, consent management (GDPR/cookie banner), ad pixels, conversion tracking, data layer implementation."
}

function Start-DataQuality {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Data Quality Check - $siteUrl"
    $basePrompt = Get-PromptContent "martech\martech-data-quality.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nCheck data quality: analytics tag firing, data layer consistency, cross-domain tracking, event tracking implementation, consent mode compliance, duplicate tags, tag loading order, PII leakage in URLs/parameters."
}

# --- Security ---
function Start-WebsiteSecurity {
    $siteUrl = Read-Host $strings.Url
    if (-not $siteUrl) { return }
    Write-Log "Task: Website Security Scan - $siteUrl"
    $basePrompt = Get-PromptContent "security\website-security.md"
    Invoke-Engine "$basePrompt`n`nTarget URL: $siteUrl`nPerform a website security scan: SSL/TLS configuration, security headers (CSP, HSTS, X-Frame-Options, etc.), exposed directories, CMS version disclosure, outdated libraries, mixed content, CORS policy, cookie security flags, information leakage."
}

function Start-SystemSecurity {
    Write-Host $strings.DiagStart -ForegroundColor Green
    Write-Log "Task: System Security Audit"
    $basePrompt = Get-PromptContent "security\system-security.md"
    Invoke-Engine "$basePrompt`n`nRun a COMPLETE and AUTONOMOUS Windows security analysis without asking for confirmation. Check: local users/groups, password policies, services running as SYSTEM, open ports, firewall, antivirus, missing updates, network shares, suspicious scheduled tasks, autorun entries, shared folder permissions, RDP configuration, SMBv1, audit policy. Do NOT ask for confirmation. Produce a structured report with severity (CRITICAL/HIGH/MEDIUM/LOW) and remediation for each issue found."
}

# --- Utilities ---
function Start-SshRemote {
    $sshHost = Read-Host $strings.SshHost
    if (-not $sshHost) { return }
    Write-Log "Task: Remote SSH Diagnostics - $sshHost"
    & $engineBin "Connect via SSH to $sshHost. Diagnose the remote system: OS, services, disk, memory, error logs, security. For each problem propose a fix and ask confirmation before applying."
}

function Start-EjectUSB {
    Write-Host $strings.EjectSync -ForegroundColor Cyan
    Write-Log "Task: Safe Eject USB"
    $driveLetter = $UsbRoot.Substring(0, 1)

    $ejectSrc = Join-Path $UsbRoot "prismo-eject.ps1"
    $ejectDst = Join-Path $env:TEMP "prismo-eject.ps1"

    if (Test-Path $ejectSrc) {
        Copy-Item $ejectSrc $ejectDst -Force
    } else {
        # Generate a minimal eject script if the file doesn't exist
        @'
param([string]$DriveLetter, [string]$MsgOk, [string]$MsgFail)
Start-Sleep -Seconds 2
try {
    $vol = Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveLetter -eq "${DriveLetter}:" }
    if ($vol) {
        $vol.Dismount($false, $false) | Out-Null
        Write-Host $MsgOk -ForegroundColor Green
    } else {
        $driveEject = New-Object -ComObject Shell.Application
        $driveEject.Namespace(17).ParseName("${DriveLetter}:\").InvokeVerb("Eject")
        Start-Sleep -Seconds 2
        if (Test-Path "${DriveLetter}:\") {
            Write-Host $MsgFail -ForegroundColor Red
        } else {
            Write-Host $MsgOk -ForegroundColor Green
        }
    }
} catch {
    Write-Host $MsgFail -ForegroundColor Red
}
Start-Sleep -Seconds 3
'@ | Out-File -FilePath $ejectDst -Encoding UTF8
    }

    Set-Location $env:TEMP
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ejectDst`" -DriveLetter `"$driveLetter`" -MsgOk `"$($strings.EjectOk)`" -MsgFail `"$($strings.EjectFail)`""
    exit 0
}

# ======================================================================
# DIRECT MODE (via -Modalita parameter)
# ======================================================================
Show-Banner

if ($Modalita -ne "menu") {
    switch ($Modalita) {
        "diagnosi"       { Start-SystemDiagnosis }
        "log"            { Start-LogAnalysis }
        "rete"           { Start-NetworkDiagnosis }
        "webperf"        { Start-WebsitePerformance }
        "techstack"      { Start-TechStack }
        "accessibility"  { Start-AccessibilityAudit }
        "seotecnico"     { Start-SeoTechnical }
        "seoonpage"      { Start-SeoOnpage }
        "seocompetitivo" { Start-SeoCompetitive }
        "martech"        { Start-MartechAudit }
        "dataquality"    { Start-DataQuality }
        "websecurity"    { Start-WebsiteSecurity }
        "syssecurity"    { Start-SystemSecurity }
        "interattivo"    { Invoke-EngineInteractive }
        "ssh"            { Start-SshRemote }
    }
    exit 0
}

# ======================================================================
# MAIN LOOP
# ======================================================================
do {
    Show-Menu
    Write-Host ""
    $choice = Read-Host "  $($strings.Choice)"
    Write-Host ""

    switch ($choice) {
        "1"  { Start-SystemDiagnosis }
        "2"  { Start-LogAnalysis }
        "3"  { Start-NetworkDiagnosis }
        "4"  { Start-WebsitePerformance }
        "5"  { Start-TechStack }
        "6"  { Start-AccessibilityAudit }
        "7"  { Start-SeoTechnical }
        "8"  { Start-SeoOnpage }
        "9"  { Start-SeoCompetitive }
        "10" { Start-MartechAudit }
        "11" { Start-DataQuality }
        "12" { Start-WebsiteSecurity }
        "13" { Start-SystemSecurity }
        "14" { Invoke-EngineInteractive }
        "15" { Start-SshRemote }
        "0"  { Start-EjectUSB }
        { $_ -eq "Q" -or $_ -eq "q" } {
            Write-Host $strings.Bye -ForegroundColor Green
            Write-Log "Session ended by user."
        }
        default {
            Write-Host $strings.Invalid -ForegroundColor Red
        }
    }
    Write-Host ""
} while ($choice -ne "Q" -and $choice -ne "q")
