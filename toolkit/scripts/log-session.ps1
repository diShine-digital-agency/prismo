<#
.SYNOPSIS
    Prismo — Session Logging Script
    Part of Prismo AI Consulting Toolkit by diShine Digital Agency
    https://dishine.it

.DESCRIPTION
    Starts a PowerShell transcript logging session. All console output is
    captured to a timestamped log file in the specified directory.

    Run this at the start of a consulting session to capture all commands
    and output for later review and documentation.

.PARAMETER LogDir
    Directory where transcript files are saved (default: toolkit/logs)

.PARAMETER SessionName
    Optional label for the session (included in the filename)

.EXAMPLE
    .\log-session.ps1
    .\log-session.ps1 -SessionName "STEF-audit"
    .\log-session.ps1 -LogDir "C:\prismo\logs" -SessionName "client-review"
#>
param(
    [string]$LogDir = (Join-Path $PSScriptRoot "..\logs"),
    [string]$SessionName = "session"
)

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Build filename
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$hostname  = $env:COMPUTERNAME
$safeName  = $SessionName -replace '[^\w\-]', '_'
$logFile   = Join-Path $LogDir "prismo_${safeName}_${hostname}_${timestamp}.log"

# Start transcript
try {
    Start-Transcript -Path $logFile -Append
    Write-Host "" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Prismo Session Logger — diShine Digital Agency" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  Session  : $SessionName" -ForegroundColor Cyan
    Write-Host "  Log File : $logFile" -ForegroundColor Cyan
    Write-Host "  Started  : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "  Host     : $hostname" -ForegroundColor Cyan
    Write-Host "  User     : $env:USERNAME" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Transcript is running. Use 'Stop-Transcript' to end logging." -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "[Prismo] Error: Failed to start transcript — $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  A transcript may already be active. Run 'Stop-Transcript' first." -ForegroundColor Yellow
    exit 1
}
