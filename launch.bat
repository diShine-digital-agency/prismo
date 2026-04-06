@echo off
setlocal enabledelayedexpansion
title Prismo - AI Consulting Toolkit by diShine Digital Agency
chcp 65001 >nul 2>&1

:: ======================================================================
:: Prismo - AI Consulting Toolkit - Windows CMD Launcher
:: Part of Prismo by diShine Digital Agency
:: https://dishine.it | https://github.com/diShine-digital-agency/prismo
:: ======================================================================

set "USB_ROOT=%~dp0"
set "USB_ROOT=%USB_ROOT:~0,-1%"

:: === READ VERSION ===
set "PRISMO_VERSION=unknown"
if exist "%USB_ROOT%\VERSION" (
    set /p PRISMO_VERSION=<"%USB_ROOT%\VERSION"
)

:: === BANNER ===
powershell -NoProfile -Command ^
  "Write-Host ''; " ^
  "Write-Host '  ================================================' -F Cyan; " ^
  "Write-Host '   ____  ____  ___ ____  __  __  ___'              -F Cyan; " ^
  "Write-Host '  |  _ \|  _ \|_ _/ ___||  \/  |/ _ \ '           -F Cyan; " ^
  "Write-Host '  | |_) | |_) || |\___ \| |\/| | | | |'           -F Cyan; " ^
  "Write-Host '  |  __/|  _ < | | ___) | |  | | |_| |'           -F Cyan; " ^
  "Write-Host '  |_|   |_| \_\___|____/|_|  |_|\___/'             -F Cyan; " ^
  "Write-Host ''; " ^
  "Write-Host '    >_ AI Consulting Toolkit' -F Cyan; " ^
  "Write-Host '       by diShine Digital Agency' -F Cyan; " ^
  "Write-Host ''; " ^
  "Write-Host '    v' -NoNewline -F DarkGray; Write-Host '%PRISMO_VERSION%' -F DarkGray; " ^
  "Write-Host '    Portable - no installation required' -F Cyan; " ^
  "Write-Host '  ================================================' -F Cyan; " ^
  "Write-Host ''; " ^
  "Write-Host '  [I] Italiano  [E] English' -F White; " ^
  "Write-Host ''"

set "LANG="
set /p "LANG=  Language / Lingua: "
if /i "%LANG%"=="E" goto set_en
goto set_it

:: ======================================================================
:: LANGUAGE: ENGLISH
:: ======================================================================
:set_en
:: Section headers
set "SEC_SYS=-- System Health --"
set "SEC_WEB=-- Web & Performance --"
set "SEC_SEO=-- SEO --"
set "SEC_MAR=-- MarTech & Data --"
set "SEC_SEC=-- Security --"
set "SEC_UTL=-- Utilities --"
:: Menu items
set "M1= [1]  System diagnosis"
set "M2= [2]  Log analysis"
set "M3= [3]  Network diagnosis"
set "M4= [4]  Website performance audit"
set "M5= [5]  Tech stack analysis"
set "M6= [6]  Accessibility audit (WCAG 2.1)"
set "M7= [7]  Technical SEO audit"
set "M8= [8]  On-page SEO analysis"
set "M9= [9]  Competitive SEO snapshot"
set "M10=[10]  MarTech stack audit"
set "M11=[11]  Data quality check"
set "M12=[12]  Website security scan"
set "M13=[13]  System security audit"
set "M14=[14]  Interactive AI session"
set "M15=[15]  Remote SSH diagnostics"
set "M0= [0]  Safe eject USB"
set "MQ= [Q]  Quit"
:: Messages
set "MSG_CHOICE=  Choice: "
set "MSG_URL=  Website URL: "
set "MSG_URLS=  Competitor URLs (comma-separated): "
set "MSG_LOGPATH=  Log file path: "
set "MSG_SSHHOST=  Host (user@ip): "
set "MSG_DIAGSTART=[*] Starting diagnosis..."
set "MSG_BYE=Goodbye. No traces left on the system."
set "MSG_BACK=Back to menu."
set "MSG_INVALID=Invalid choice."
set "MSG_NOTFOUND=[ERROR] File not found."
set "MSG_EJECT_SYNC=Flushing buffers..."
set "MSG_EJECT_OK=USB safely ejected. You can remove the drive now."
set "MSG_EJECT_FAIL=Could not eject the USB drive. Close all open files and try again."
goto env_setup

:: ======================================================================
:: LANGUAGE: ITALIAN
:: ======================================================================
:set_it
:: Section headers
set "SEC_SYS=-- Sistema --"
set "SEC_WEB=-- Web & Performance --"
set "SEC_SEO=-- SEO --"
set "SEC_MAR=-- MarTech & Dati --"
set "SEC_SEC=-- Sicurezza --"
set "SEC_UTL=-- Utilita' --"
:: Menu items
set "M1= [1]  Diagnosi sistema"
set "M2= [2]  Analisi log"
set "M3= [3]  Diagnosi rete"
set "M4= [4]  Audit performance sito web"
set "M5= [5]  Analisi tech stack"
set "M6= [6]  Audit accessibilita' (WCAG 2.1)"
set "M7= [7]  Audit SEO tecnico"
set "M8= [8]  Analisi SEO on-page"
set "M9= [9]  Snapshot SEO competitivo"
set "M10=[10]  Audit stack MarTech"
set "M11=[11]  Controllo qualita' dati"
set "M12=[12]  Scansione sicurezza sito web"
set "M13=[13]  Audit sicurezza sistema"
set "M14=[14]  Sessione AI interattiva"
set "M15=[15]  Diagnostica remota SSH"
set "M0= [0]  Sgancia chiavetta USB"
set "MQ= [Q]  Esci"
:: Messages
set "MSG_CHOICE=  Scelta: "
set "MSG_URL=  URL del sito web: "
set "MSG_URLS=  URL competitor (separati da virgola): "
set "MSG_LOGPATH=  Percorso file di log: "
set "MSG_SSHHOST=  Host (user@ip): "
set "MSG_DIAGSTART=[*] Avvio diagnosi..."
set "MSG_BYE=Arrivederci. Nessuna traccia lasciata sul sistema."
set "MSG_BACK=Torna al menu."
set "MSG_INVALID=Scelta non valida."
set "MSG_NOTFOUND=[ERRORE] File non trovato."
set "MSG_EJECT_SYNC=Scaricamento buffer in corso..."
set "MSG_EJECT_OK=Chiavetta USB sganciata in sicurezza. Puoi rimuoverla."
set "MSG_EJECT_FAIL=Impossibile sganciare la chiavetta. Chiudi tutti i file aperti e riprova."
goto env_setup

:: ======================================================================
:: ENVIRONMENT SETUP
:: ======================================================================
:env_setup

set "NODE_DIR=%USB_ROOT%\runtime\node-win-x64"
if not exist "%NODE_DIR%\node.exe" (
    echo [ERROR] Node.js not found in %NODE_DIR%
    echo Run setup-usb.ps1 first to prepare the USB drive.
    pause
    exit /b 1
)

set "CLAUDE_BIN=%USB_ROOT%\engine\bin\claude.cmd"
if not exist "%CLAUDE_BIN%" (
    :: Try legacy location
    if exist "%USB_ROOT%\engine\claude.cmd" (
        set "CLAUDE_BIN=%USB_ROOT%\engine\claude.cmd"
        goto claude_ok
    )
    echo [*] AI engine not found, attempting auto-repair...
    for %%F in ("%USB_ROOT%\engine\.claude.cmd-*") do (
        copy "%%F" "%CLAUDE_BIN%" >nul 2>&1
        echo [OK] AI engine restored from %%~nxF
        goto claude_ok
    )
    :: Try cli.js wrapper
    if exist "%USB_ROOT%\engine\node_modules\@anthropic-ai\claude-code\cli.js" (
        echo @echo off > "%CLAUDE_BIN%"
        echo "%NODE_DIR%\node.exe" "%USB_ROOT%\engine\node_modules\@anthropic-ai\claude-code\cli.js" %%* >> "%CLAUDE_BIN%"
        echo [OK] AI engine generated from cli.js
        goto claude_ok
    )
    if exist "%USB_ROOT%\engine\lib\node_modules\@anthropic-ai\claude-code\cli.js" (
        echo @echo off > "%CLAUDE_BIN%"
        echo "%NODE_DIR%\node.exe" "%USB_ROOT%\engine\lib\node_modules\@anthropic-ai\claude-code\cli.js" %%* >> "%CLAUDE_BIN%"
        echo [OK] AI engine generated from cli.js
        goto claude_ok
    )
    echo [ERROR] AI engine not found. Run setup-usb.ps1 first.
    pause
    exit /b 1
)
:claude_ok

set "PATH=%NODE_DIR%;%USB_ROOT%\engine\bin;%PATH%"
set "NPM_CONFIG_PREFIX=%USB_ROOT%\engine"
set "CLAUDE_CONFIG_DIR=%USB_ROOT%\config"
set "NODE_PATH=%USB_ROOT%\engine\lib\node_modules"

:: Detect cli.js node_modules for NODE_PATH override
if exist "%USB_ROOT%\engine\node_modules\@anthropic-ai\claude-code\cli.js" (
    set "NODE_PATH=%USB_ROOT%\engine\node_modules"
)

:: Detect Git Portable
set "GIT_DIR=%USB_ROOT%\runtime\git-win-x64"
if exist "%GIT_DIR%\bin\bash.exe" (
    set "CLAUDE_CODE_GIT_BASH_PATH=%GIT_DIR%\bin\bash.exe"
    set "PATH=%GIT_DIR%\bin;%GIT_DIR%\cmd;%PATH%"
)

:: ======================================================================
:: CHECKSUM VERIFICATION
:: ======================================================================
if exist "%USB_ROOT%\SHA256SUMS" (
    set "CHECKSUM_FAIL=0"
    for /f "tokens=1,2" %%A in (%USB_ROOT%\SHA256SUMS) do (
        if exist "%USB_ROOT%\%%B" (
            for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Path '%USB_ROOT%\%%B' -Algorithm SHA256).Hash.ToLower()"') do (
                if /i not "%%H"=="%%A" set "CHECKSUM_FAIL=1"
            )
        )
    )
    if "!CHECKSUM_FAIL!"=="1" (
        powershell -NoProfile -Command "Write-Host 'WARNING: One or more scripts have been modified! The USB drive may have been tampered with.' -F Red"
        echo.
        pause
    )
)

:: ======================================================================
:: SESSION LOGGING
:: ======================================================================
if not exist "%USB_ROOT%\toolkit\logs" mkdir "%USB_ROOT%\toolkit\logs"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul ^| find "="') do set "DT=%%I"
set "LOG_FILE=%USB_ROOT%\toolkit\logs\session-%DT:~0,8%-%DT:~8,6%.log"
echo === Prismo Session Log === > "%LOG_FILE%"
echo Date: %DATE% %TIME% >> "%LOG_FILE%"
echo Hostname: %COMPUTERNAME% >> "%LOG_FILE%"
echo OS: Windows >> "%LOG_FILE%"
echo ========================= >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo [OK] Environment configured.
echo.

:: ======================================================================
:: MAIN MENU
:: ======================================================================
:menu
echo.
powershell -NoProfile -Command ^
  "Write-Host '  +-----------------------------------------------+' -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_SYS%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M1%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M2%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M3%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_WEB%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M4%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M5%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M6%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_SEO%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M7%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M8%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M9%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_MAR%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M10%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M11%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_SEC%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M12%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M13%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%SEC_UTL%'.PadRight(41) + '|') -F Green; " ^
  "Write-Host ('  |  ' + '%M14%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M15%'.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + ''.PadRight(41) + '|') -F Cyan; " ^
  "Write-Host ('  |  ' + '%M0%'.PadRight(41) + '|') -F DarkGray; " ^
  "Write-Host ('  |  ' + '%MQ%'.PadRight(41) + '|') -F DarkGray; " ^
  "Write-Host '  +-----------------------------------------------+' -F Cyan"
echo.
set "CHOICE="
set /p "CHOICE=%MSG_CHOICE%"

if "%CHOICE%"=="1"  goto opt_system_diag
if "%CHOICE%"=="2"  goto opt_log_analysis
if "%CHOICE%"=="3"  goto opt_network_diag
if "%CHOICE%"=="4"  goto opt_web_perf
if "%CHOICE%"=="5"  goto opt_tech_stack
if "%CHOICE%"=="6"  goto opt_accessibility
if "%CHOICE%"=="7"  goto opt_seo_technical
if "%CHOICE%"=="8"  goto opt_seo_onpage
if "%CHOICE%"=="9"  goto opt_seo_competitive
if "%CHOICE%"=="10" goto opt_martech
if "%CHOICE%"=="11" goto opt_data_quality
if "%CHOICE%"=="12" goto opt_web_security
if "%CHOICE%"=="13" goto opt_sys_security
if "%CHOICE%"=="14" goto opt_interactive
if "%CHOICE%"=="15" goto opt_ssh
if "%CHOICE%"=="0"  goto opt_eject
if /i "%CHOICE%"=="Q" goto opt_quit
echo %MSG_INVALID%
echo.
goto menu

:: ======================================================================
:: OPTION HANDLERS
:: ======================================================================

:: --- [1] System Diagnosis ---
:opt_system_diag
echo.
echo %MSG_DIAGSTART%
echo [%DATE% %TIME%] system_diagnosis >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Run a COMPLETE and AUTONOMOUS Windows system diagnosis without asking for confirmation. Check: critical services (status and startup type), disk space on all volumes, RAM/CPU usage, Event Log errors (last 24h), network interfaces/DNS/gateway, pending Windows updates, antivirus/firewall status, failed scheduled tasks. For each problem: explain impact, assign severity (CRITICAL/HIGH/MEDIUM/LOW), and propose remediation. Do NOT ask for confirmation between checks."
echo [%DATE% %TIME%] system_diagnosis: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [2] Log Analysis ---
:opt_log_analysis
echo.
set "LOGPATH="
set /p "LOGPATH=%MSG_LOGPATH%"
if "%LOGPATH%"=="" goto menu
if not exist "%LOGPATH%" (
    echo %MSG_NOTFOUND%
    goto menu
)
echo [%DATE% %TIME%] log_analysis: %LOGPATH% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Analyze the log file '%LOGPATH%'. Identify errors, warnings, and anomalous patterns. Provide a structured summary with severity levels and suggest concrete solutions."
echo [%DATE% %TIME%] log_analysis: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [3] Network Diagnosis ---
:opt_network_diag
echo.
echo %MSG_DIAGSTART%
echo [%DATE% %TIME%] network_diagnosis >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Run a complete Windows network diagnosis: interfaces, IP configuration, DNS, gateway, routing table, listening ports, active connections, firewall rules, internet and DNS connectivity test. Identify problems and propose fixes."
echo [%DATE% %TIME%] network_diagnosis: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [4] Website Performance Audit ---
:opt_web_perf
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] website_performance: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform a comprehensive website performance audit for %SITE_URL%. Analyze: Core Web Vitals (LCP, FID, CLS), loading performance, render-blocking resources, image optimization, caching headers, compression (gzip/brotli), page weight, number of requests, JavaScript execution time, font loading strategy. Generate a structured Markdown report with severity and actionable recommendations."
echo [%DATE% %TIME%] website_performance: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [5] Tech Stack Analysis ---
:opt_tech_stack
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] tech_stack: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Analyze the technology stack of %SITE_URL%. Identify: CMS/framework, JavaScript libraries and versions, analytics tools, CDN provider, hosting/server software, tag managers, marketing tools, A/B testing platforms, third-party integrations, API endpoints. Present findings in a structured table format."
echo [%DATE% %TIME%] tech_stack: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [6] Accessibility Audit ---
:opt_accessibility
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] accessibility_audit: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform a WCAG 2.1 AA accessibility audit of %SITE_URL%. Check: semantic HTML structure, ARIA attributes, color contrast ratios, keyboard navigation, alt text for images, form labels, focus management, skip navigation links, responsive design, screen reader compatibility, language attributes, error identification, timing adjustable content. Produce a structured report with conformance level per criterion and remediation guidance."
echo [%DATE% %TIME%] accessibility_audit: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [7] Technical SEO Audit ---
:opt_seo_technical
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] seo_technical: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform a technical SEO audit of %SITE_URL%. Check: robots.txt configuration, sitemap.xml validity, canonical tags, hreflang implementation, structured data/Schema.org markup, page speed signals, mobile-friendliness, crawlability, indexation status, redirect chains/loops, HTTP status codes, SSL certificate, Core Web Vitals, JavaScript rendering, URL structure. Produce a structured report with priority and fix instructions."
echo [%DATE% %TIME%] seo_technical: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [8] On-page SEO Analysis ---
:opt_seo_onpage
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] seo_onpage: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform an on-page SEO analysis of %SITE_URL%. Analyze: title tags (length, keyword placement), meta descriptions, heading hierarchy (H1-H6), content quality and depth, keyword usage and density, internal linking structure, image optimization (alt, size, format), URL structure, content freshness signals, E-E-A-T indicators, open graph and social meta tags. Produce a structured report with scoring and actionable improvements."
echo [%DATE% %TIME%] seo_onpage: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [9] Competitive SEO Snapshot ---
:opt_seo_competitive
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
set "COMP_URLS="
set /p "COMP_URLS=%MSG_URLS%"
echo [%DATE% %TIME%] seo_competitive: %SITE_URL% vs %COMP_URLS% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform a competitive SEO comparison. Client URL: %SITE_URL%. Competitor URLs: %COMP_URLS%. Compare: domain authority signals, content strategy and depth, keyword targeting overlap, backlink profile indicators, technical SEO maturity, SERP feature usage, site speed, mobile optimization, structured data adoption. Produce a comparative matrix with strengths, weaknesses, and strategic recommendations."
echo [%DATE% %TIME%] seo_competitive: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [10] MarTech Stack Audit ---
:opt_martech
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] martech_audit: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Audit the MarTech stack of %SITE_URL%. Identify and evaluate: tag managers (GTM config), analytics platforms (GA4 setup, event tracking), CRM integrations, marketing automation tools, A/B testing platforms, heatmap/session recording tools, consent management platform (GDPR/cookie banner compliance), advertising pixels (Meta, Google Ads, LinkedIn), conversion tracking setup, data layer implementation. Assess integration quality and identify gaps or redundancies."
echo [%DATE% %TIME%] martech_audit: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [11] Data Quality Check ---
:opt_data_quality
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] data_quality: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Check data quality for %SITE_URL%. Verify: analytics tag firing correctness, data layer consistency and structure, cross-domain tracking configuration, event tracking implementation quality, consent mode compliance (Google Consent Mode v2), duplicate or conflicting tags, tag loading order and performance impact, PII leakage in URLs/parameters/data layer, referral exclusions, internal traffic filtering. Produce a report with data integrity score and remediation steps."
echo [%DATE% %TIME%] data_quality: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [12] Website Security Scan ---
:opt_web_security
echo.
set "SITE_URL="
set /p "SITE_URL=%MSG_URL%"
if "%SITE_URL%"=="" goto menu
echo [%DATE% %TIME%] website_security: %SITE_URL% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Perform a website security scan of %SITE_URL%. Check: SSL/TLS configuration and grade, security headers (Content-Security-Policy, Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy), exposed directories and files, CMS version disclosure, outdated JavaScript libraries with known CVEs, mixed content warnings, CORS policy, cookie security flags (Secure, HttpOnly, SameSite), server information leakage, open redirects, form security (CSRF tokens). Produce a structured report with severity and remediation."
echo [%DATE% %TIME%] website_security: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [13] System Security Audit ---
:opt_sys_security
echo.
echo %MSG_DIAGSTART%
echo [%DATE% %TIME%] system_security >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Run a COMPLETE and AUTONOMOUS Windows security analysis without asking for confirmation. Check: local users and groups, password policies, services running as SYSTEM, open ports, firewall configuration, antivirus status, missing security updates, network shares and permissions, suspicious scheduled tasks, autorun entries, shared folder permissions, RDP configuration, SMBv1 status, audit policy, BitLocker status, Windows Defender settings. Do NOT ask for confirmation. Do NOT stop between checks. Produce a structured report with severity (CRITICAL/HIGH/MEDIUM/LOW) and remediation for each issue found."
echo [%DATE% %TIME%] system_security: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [14] Interactive AI session ---
:opt_interactive
echo.
echo [%DATE% %TIME%] interactive: session started >> "%LOG_FILE%"
call "%CLAUDE_BIN%"
echo [%DATE% %TIME%] interactive: session ended >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [15] Remote SSH Diagnostics ---
:opt_ssh
echo.
set "SSH_HOST="
set /p "SSH_HOST=%MSG_SSHHOST%"
if "%SSH_HOST%"=="" goto menu
echo [%DATE% %TIME%] ssh_remote: %SSH_HOST% >> "%LOG_FILE%"
call "%CLAUDE_BIN%" "Connect via SSH to %SSH_HOST%. Diagnose the remote system: OS, services, disk usage, memory, error logs, security posture. For each problem found, propose a fix and ask for confirmation before applying it."
echo [%DATE% %TIME%] ssh_remote: completed >> "%LOG_FILE%"
echo.
echo %MSG_BACK%
echo.
goto menu

:: --- [0] Safe Eject USB ---
:opt_eject
echo.
echo %MSG_EJECT_SYNC%
set "USB_DRIVE=%USB_ROOT:~0,2%"
set "USB_LETTER=%USB_ROOT:~0,1%"
echo [%DATE% %TIME%] eject: %USB_DRIVE% >> "%LOG_FILE%"

if exist "%USB_ROOT%\prismo-eject.ps1" (
    copy "%USB_ROOT%\prismo-eject.ps1" "%TEMP%\prismo-eject.ps1" >nul 2>&1
    cd /d "%TEMP%"
    start "" /D "%TEMP%" powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\prismo-eject.ps1" -DriveLetter "%USB_LETTER%" -MsgOk "%MSG_EJECT_OK%" -MsgFail "%MSG_EJECT_FAIL%"
    exit
)
:: Inline eject fallback
cd /d "%TEMP%"
powershell -NoProfile -Command ^
  "Start-Sleep -Seconds 2; " ^
  "try { " ^
  "  $shell = New-Object -ComObject Shell.Application; " ^
  "  $shell.Namespace(17).ParseName('%USB_DRIVE%\').InvokeVerb('Eject'); " ^
  "  Start-Sleep -Seconds 2; " ^
  "  if (Test-Path '%USB_DRIVE%\') { Write-Host '%MSG_EJECT_FAIL%' -F Red } " ^
  "  else { Write-Host '%MSG_EJECT_OK%' -F Green } " ^
  "} catch { Write-Host '%MSG_EJECT_FAIL%' -F Red }; " ^
  "Start-Sleep -Seconds 3"
exit

:: --- [Q] Quit ---
:opt_quit
echo %MSG_BYE%
echo [%DATE% %TIME%] session ended >> "%LOG_FILE%"
timeout /t 2 >nul
exit /b 0
