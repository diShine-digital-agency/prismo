#Requires -Version 5.1
<#
.SYNOPSIS
    Prismo USB Setup — Prepares a portable USB drive with AI engine and diagnostic tools.
    Run this script ONCE from your main PC to configure the USB drive.

.DESCRIPTION
    Downloads Node.js, Git Portable, AI engine, and optional web audit tools
    (Lighthouse, pa11y) onto a USB drive for cross-platform portable use.

    Part of Prismo — AI Consulting Toolkit by diShine Digital Agency.
    https://dishine.it | https://github.com/diShine-digital-agency/prismo

.PARAMETER UsbDrive
    USB drive letter (e.g., "E", "F")

.PARAMETER NodeVersion
    Node.js version to download (default: 22.14.0)

.PARAMETER SkipWebTools
    Skip installation of web audit tools (Lighthouse, pa11y)

.EXAMPLE
    .\setup-usb.ps1 -UsbDrive E
    .\setup-usb.ps1 -UsbDrive F -SkipWebTools
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]$')]
    [string]$UsbDrive,

    [string]$NodeVersion = "22.14.0",

    [switch]$SkipWebTools
)

$ErrorActionPreference = "Stop"
$UsbRoot = "${UsbDrive}:\"

# --- Progress Bar ---
$totalSteps = 10
$currentStep = 0

function Show-SetupProgress {
    param(
        [int]$Step,
        [string]$Activity,
        [string]$Status = "",
        [int]$PercentWithinStep = -1
    )
    $overallPercent = [math]::Floor(($Step - 1) / $totalSteps * 100)
    if ($PercentWithinStep -ge 0) {
        $stepContribution = [math]::Floor($PercentWithinStep / $totalSteps)
        $overallPercent = [math]::Min($overallPercent + $stepContribution, 100)
    }

    $barWidth = 40
    $filled = [math]::Floor($overallPercent / 100 * $barWidth)
    $empty = $barWidth - $filled
    $bar = "[" + ("#" * $filled) + ("-" * $empty) + "]"

    $progressLine = "`r  $bar $overallPercent% - Step $Step/$totalSteps"
    if ($Status) { $progressLine += " - $Status" }
    Write-Host $progressLine -NoNewline -ForegroundColor Cyan

    $progressParams = @{
        Activity = "Prismo USB Setup"
        Status = "[$Step/$totalSteps] $Activity"
        PercentComplete = $overallPercent
    }
    if ($Status) { $progressParams["CurrentOperation"] = $Status }
    Write-Progress @progressParams
}

function Complete-Step {
    param([int]$Step, [string]$Activity)
    $overallPercent = [math]::Floor($Step / $totalSteps * 100)
    $barWidth = 40
    $filled = [math]::Floor($overallPercent / 100 * $barWidth)
    $empty = $barWidth - $filled
    $bar = "[" + ("#" * $filled) + ("-" * $empty) + "]"
    Write-Host "`r  $bar $overallPercent% - Step $Step/$totalSteps - Done!   " -ForegroundColor Green
}

function Invoke-DownloadWithProgress {
    param(
        [string]$Uri,
        [string]$OutFile,
        [int]$Step,
        [string]$Label,
        [int]$MaxRetries = 2
    )
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            $webRequest = [System.Net.HttpWebRequest]::Create($Uri)
            $webRequest.Timeout = 120000
            $response = $webRequest.GetResponse()
            $totalBytes = $response.ContentLength
            $stream = $response.GetResponseStream()
            $fileStream = [System.IO.File]::Create($OutFile)
            $buffer = New-Object byte[] 65536
            $downloaded = 0
            $lastUpdate = [DateTime]::Now

            while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fileStream.Write($buffer, 0, $bytesRead)
                $downloaded += $bytesRead
                $now = [DateTime]::Now
                if (($now - $lastUpdate).TotalMilliseconds -ge 200) {
                    $lastUpdate = $now
                    if ($totalBytes -gt 0) {
                        $dlPercent = [math]::Floor($downloaded / $totalBytes * 100)
                        $dlMB = [math]::Round($downloaded / 1MB, 1)
                        $totalMB = [math]::Round($totalBytes / 1MB, 1)
                        Show-SetupProgress -Step $Step -Activity $Label -Status "${dlMB}MB / ${totalMB}MB ($dlPercent%)" -PercentWithinStep $dlPercent
                    }
                }
            }
            $fileStream.Close()
            $stream.Close()
            $response.Close()
            return
        } catch {
            if ($i -eq $MaxRetries) { throw }
            Write-Host ""
            Write-Host "  [RETRY] Attempt $i failed, retrying..." -ForegroundColor Yellow
        }
    }
}

# --- Validation ---
if (-not (Test-Path $UsbRoot)) {
    Write-Error "Drive ${UsbDrive}: not found. Please insert the USB drive."
    exit 1
}

$freeSpace = (Get-PSDrive $UsbDrive).Free
$requiredSpace = 900MB
if ($freeSpace -lt $requiredSpace) {
    Write-Error "Insufficient space. Need at least 900MB free. Available: $([math]::Round($freeSpace / 1MB))MB"
    exit 1
}

Write-Host ""
Write-Host "  +============================================+" -ForegroundColor Cyan
Write-Host "  |   PRISMO USB SETUP                        |" -ForegroundColor Cyan
Write-Host "  |   AI Consulting Toolkit by diShine        |" -ForegroundColor Cyan
Write-Host "  +============================================+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  USB Drive: ${UsbDrive}:   Node.js: $NodeVersion" -ForegroundColor Yellow
Write-Host ""

# --- Step 1: Create directory structure ---
$currentStep = 1
Show-SetupProgress -Step $currentStep -Activity "Creating directories" -Status "Preparing structure..."
Write-Host ""
Write-Host "  [1/$totalSteps] Creating directory structure..." -ForegroundColor Green

$directories = @(
    "runtime\node-win-x64",
    "runtime\node-linux-x64",
    "runtime\node-darwin-x64",
    "runtime\node-darwin-arm64",
    "runtime\git-win-x64",
    "engine",
    "config",
    "config\rules",
    "toolkit\prompts\system",
    "toolkit\prompts\web",
    "toolkit\prompts\seo",
    "toolkit\prompts\martech",
    "toolkit\prompts\security",
    "toolkit\scripts",
    "toolkit\logs",
    "toolkit\reports",
    "toolkit\clients"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $UsbRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}
Complete-Step -Step $currentStep -Activity "Creating directories"

# --- Step 2: Download Node.js Windows ---
$currentStep = 2
Show-SetupProgress -Step $currentStep -Activity "Node.js Windows" -Status "Starting download..."
Write-Host ""
Write-Host "  [2/$totalSteps] Downloading Node.js $NodeVersion for Windows x64..." -ForegroundColor Green

$nodeWinZip = Join-Path $env:TEMP "node-win-x64.zip"
$nodeWinUrl = "https://nodejs.org/dist/v${NodeVersion}/node-v${NodeVersion}-win-x64.zip"
$nodeWinDest = Join-Path $UsbRoot "runtime\node-win-x64"

if (-not (Test-Path (Join-Path $nodeWinDest "node.exe"))) {
    Invoke-DownloadWithProgress -Uri $nodeWinUrl -OutFile $nodeWinZip -Step $currentStep -Label "Node.js Windows"
    Write-Host ""
    Show-SetupProgress -Step $currentStep -Activity "Node.js Windows" -Status "Extracting..." -PercentWithinStep 80
    Write-Host ""
    Expand-Archive -Path $nodeWinZip -DestinationPath (Join-Path $env:TEMP "node-win-extract") -Force
    $extractedDir = Get-ChildItem (Join-Path $env:TEMP "node-win-extract") | Select-Object -First 1
    Copy-Item -Path "$($extractedDir.FullName)\*" -Destination $nodeWinDest -Recurse -Force
    Remove-Item $nodeWinZip -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $env:TEMP "node-win-extract") -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  Already present, skipping." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Node.js Windows"

# --- Step 3: Download Node.js Linux ---
$currentStep = 3
Show-SetupProgress -Step $currentStep -Activity "Node.js Linux" -Status "Starting download..."
Write-Host ""
Write-Host "  [3/$totalSteps] Downloading Node.js $NodeVersion for Linux x64..." -ForegroundColor Green

$nodeLinuxTar = Join-Path $env:TEMP "node-linux-x64.tar.xz"
$nodeLinuxUrl = "https://nodejs.org/dist/v${NodeVersion}/node-v${NodeVersion}-linux-x64.tar.xz"
$nodeLinuxDest = Join-Path $UsbRoot "runtime\node-linux-x64"

if (-not (Test-Path (Join-Path $nodeLinuxDest "bin"))) {
    Invoke-DownloadWithProgress -Uri $nodeLinuxUrl -OutFile $nodeLinuxTar -Step $currentStep -Label "Node.js Linux"
    Write-Host ""
    Copy-Item $nodeLinuxTar -Destination $nodeLinuxDest -Force
    Remove-Item $nodeLinuxTar -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  Already present, skipping." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Node.js Linux"

# --- Step 4: Download Node.js macOS x64 ---
$currentStep = 4
Show-SetupProgress -Step $currentStep -Activity "Node.js macOS x64" -Status "Starting download..."
Write-Host ""
Write-Host "  [4/$totalSteps] Downloading Node.js $NodeVersion for macOS x64..." -ForegroundColor Green

$nodeMacX64Tar = Join-Path $env:TEMP "node-mac-x64.tar.gz"
$nodeMacX64Url = "https://nodejs.org/dist/v${NodeVersion}/node-v${NodeVersion}-darwin-x64.tar.gz"
$nodeMacX64Dest = Join-Path $UsbRoot "runtime\node-darwin-x64"

if (-not (Test-Path (Join-Path $nodeMacX64Dest "bin"))) {
    Invoke-DownloadWithProgress -Uri $nodeMacX64Url -OutFile $nodeMacX64Tar -Step $currentStep -Label "Node.js macOS x64"
    Write-Host ""
    Copy-Item $nodeMacX64Tar -Destination $nodeMacX64Dest -Force
    Remove-Item $nodeMacX64Tar -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  Already present, skipping." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Node.js macOS x64"

# --- Step 5: Download Node.js macOS ARM64 ---
$currentStep = 5
Show-SetupProgress -Step $currentStep -Activity "Node.js macOS ARM64" -Status "Starting download..."
Write-Host ""
Write-Host "  [5/$totalSteps] Downloading Node.js $NodeVersion for macOS ARM64..." -ForegroundColor Green

$nodeMacArm64Tar = Join-Path $env:TEMP "node-mac-arm64.tar.gz"
$nodeMacArm64Url = "https://nodejs.org/dist/v${NodeVersion}/node-v${NodeVersion}-darwin-arm64.tar.gz"
$nodeMacArm64Dest = Join-Path $UsbRoot "runtime\node-darwin-arm64"

if (-not (Test-Path (Join-Path $nodeMacArm64Dest "bin"))) {
    Invoke-DownloadWithProgress -Uri $nodeMacArm64Url -OutFile $nodeMacArm64Tar -Step $currentStep -Label "Node.js macOS ARM64"
    Write-Host ""
    Copy-Item $nodeMacArm64Tar -Destination $nodeMacArm64Dest -Force
    Remove-Item $nodeMacArm64Tar -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  Already present, skipping." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Node.js macOS ARM64"

# --- Step 6: Download Git Portable ---
$currentStep = 6
Show-SetupProgress -Step $currentStep -Activity "Git Portable" -Status "Starting download..."
Write-Host ""
Write-Host "  [6/$totalSteps] Downloading Git Portable for Windows..." -ForegroundColor Green

$gitVersion = "2.47.1"
$gitPortableUrl = "https://github.com/git-for-windows/git/releases/download/v${gitVersion}.windows.1/PortableGit-${gitVersion}-64-bit.7z.exe"
$gitDest = Join-Path $UsbRoot "runtime\git-win-x64"

if (-not (Test-Path (Join-Path $gitDest "bin\bash.exe"))) {
    $gitInstaller = Join-Path $env:TEMP "PortableGit.exe"
    Invoke-DownloadWithProgress -Uri $gitPortableUrl -OutFile $gitInstaller -Step $currentStep -Label "Git Portable" -MaxRetries 2
    Write-Host ""
    $gitTempDir = Join-Path $env:TEMP "git-portable-extract"
    Show-SetupProgress -Step $currentStep -Activity "Git Portable" -Status "Extracting locally..." -PercentWithinStep 60
    Write-Host ""
    if (Test-Path $gitTempDir) { Remove-Item $gitTempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $gitTempDir -Force | Out-Null
    & $gitInstaller -o"$gitTempDir" -y 2>&1 | Out-Null
    Show-SetupProgress -Step $currentStep -Activity "Git Portable" -Status "Copying to USB..." -PercentWithinStep 80
    Write-Host ""
    if (-not (Test-Path $gitDest)) { New-Item -ItemType Directory -Path $gitDest -Force | Out-Null }
    & robocopy $gitTempDir $gitDest /E /NFL /NDL /NP 2>&1 | Out-Null
    Remove-Item $gitInstaller -Force -ErrorAction SilentlyContinue
    Remove-Item $gitTempDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  Already present, skipping." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Git Portable"

# --- Step 7: Install AI Engine ---
$currentStep = 7
Show-SetupProgress -Step $currentStep -Activity "AI Engine" -Status "Installing via npm..."
Write-Host ""
Write-Host "  [7/$totalSteps] Installing AI engine..." -ForegroundColor Green

$nodePath = Join-Path $UsbRoot "runtime\node-win-x64\node.exe"
$npmPath = Join-Path $UsbRoot "runtime\node-win-x64\npm.cmd"
$engineDir = Join-Path $UsbRoot "engine"
$engineTempDir = Join-Path $env:TEMP "engine-install"

$env:PATH = "$(Join-Path $UsbRoot 'runtime\node-win-x64');$env:PATH"

Show-SetupProgress -Step $currentStep -Activity "AI Engine" -Status "npm install (this may take a few minutes)..." -PercentWithinStep 10
Write-Host ""
if (Test-Path $engineTempDir) { Remove-Item $engineTempDir -Recurse -Force }
& $npmPath install -g @anthropic-ai/claude-code --prefix $engineTempDir 2>&1 | ForEach-Object {
    if ($_ -match "added|updated|claude") { Write-Host "  $_" -ForegroundColor Gray }
}

Show-SetupProgress -Step $currentStep -Activity "AI Engine" -Status "Copying to USB..." -PercentWithinStep 70
Write-Host ""
& robocopy $engineTempDir $engineDir /E /NFL /NDL /NP /IS /IT 2>&1 | Out-Null
Remove-Item $engineTempDir -Recurse -Force -ErrorAction SilentlyContinue
Complete-Step -Step $currentStep -Activity "AI Engine"

# --- Step 8: Install Web Audit Tools (optional) ---
$currentStep = 8
if (-not $SkipWebTools) {
    Show-SetupProgress -Step $currentStep -Activity "Web Audit Tools" -Status "Installing Lighthouse & pa11y..."
    Write-Host ""
    Write-Host "  [8/$totalSteps] Installing web audit tools (Lighthouse, pa11y)..." -ForegroundColor Green

    $webToolsTempDir = Join-Path $env:TEMP "prismo-webtools-install"
    if (Test-Path $webToolsTempDir) { Remove-Item $webToolsTempDir -Recurse -Force }

    Show-SetupProgress -Step $currentStep -Activity "Web Audit Tools" -Status "npm install lighthouse..." -PercentWithinStep 20
    Write-Host ""
    & $npmPath install -g lighthouse --prefix $webToolsTempDir 2>&1 | Out-Null

    Show-SetupProgress -Step $currentStep -Activity "Web Audit Tools" -Status "npm install pa11y..." -PercentWithinStep 50
    Write-Host ""
    & $npmPath install -g pa11y --prefix $webToolsTempDir 2>&1 | Out-Null

    Show-SetupProgress -Step $currentStep -Activity "Web Audit Tools" -Status "Copying to USB..." -PercentWithinStep 80
    Write-Host ""
    & robocopy $webToolsTempDir $engineDir /E /NFL /NDL /NP /IS /IT 2>&1 | Out-Null
    Remove-Item $webToolsTempDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  [8/$totalSteps] Skipping web audit tools (--SkipWebTools)." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Web Audit Tools"

# --- Step 9: Authentication ---
$currentStep = 9
Show-SetupProgress -Step $currentStep -Activity "Authentication" -Status "Login..."
Write-Host ""
Write-Host "  [9/$totalSteps] Configuring authentication..." -ForegroundColor Green

$env:CLAUDE_CONFIG_DIR = Join-Path $UsbRoot "config"
$engineBin = Join-Path $engineDir "bin\claude.cmd"

if (Test-Path $engineBin) {
    Write-Host "  Starting login... Follow the instructions in your browser." -ForegroundColor Yellow
    & $engineBin login
} else {
    Write-Host "  WARNING: claude.cmd not found at $engineBin" -ForegroundColor Red
    Write-Host "  You can log in manually after setup." -ForegroundColor Yellow
}
Complete-Step -Step $currentStep -Activity "Authentication"

# --- Step 10: Copy launcher and toolkit ---
$currentStep = 10
Show-SetupProgress -Step $currentStep -Activity "Launcher & toolkit" -Status "Copying files..."
Write-Host ""
Write-Host "  [10/$totalSteps] Copying launcher and toolkit to USB..." -ForegroundColor Green

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$filesToCopy = @(
    "launch.bat",
    "launch.ps1",
    "launch.sh",
    "prismo-eject.ps1",
    "prismo.config.json",
    "VERSION",
    "README.md",
    "GUIDE.md",
    "CHANGELOG.md",
    "toolkit\prompts\system\windows-health.md",
    "toolkit\prompts\system\linux-health.md",
    "toolkit\prompts\system\macos-health.md",
    "toolkit\prompts\system\log-analysis.md",
    "toolkit\prompts\system\network-diagnosis.md",
    "toolkit\prompts\web\website-performance.md",
    "toolkit\prompts\web\tech-stack-analysis.md",
    "toolkit\prompts\web\accessibility-audit.md",
    "toolkit\prompts\seo\seo-technical.md",
    "toolkit\prompts\seo\seo-onpage.md",
    "toolkit\prompts\seo\seo-competitive.md",
    "toolkit\prompts\martech\martech-stack-audit.md",
    "toolkit\prompts\martech\martech-data-quality.md",
    "toolkit\prompts\security\website-security.md",
    "toolkit\prompts\security\system-security.md",
    "toolkit\scripts\collect-win.ps1",
    "toolkit\scripts\collect-linux.sh",
    "toolkit\scripts\collect-macos.sh",
    "toolkit\scripts\collect-web.sh",
    "toolkit\scripts\log-session.ps1"
)

foreach ($file in $filesToCopy) {
    $source = Join-Path $scriptDir $file
    $dest = Join-Path $UsbRoot $file
    if (Test-Path $source) {
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item $source $dest -Force
        Write-Host "  Copied: $file" -ForegroundColor Gray
    }
}
Complete-Step -Step $currentStep -Activity "Launcher & toolkit"

# --- Generate SHA256SUMS ---
Write-Host "  Generating SHA256SUMS..." -ForegroundColor Gray
$hashFiles = @("launch.bat", "launch.sh", "launch.ps1", "prismo-eject.ps1")
$hashLines = @()
foreach ($hf in $hashFiles) {
    $hfPath = Join-Path $UsbRoot $hf
    if (Test-Path $hfPath) {
        $hash = (Get-FileHash -Path $hfPath -Algorithm SHA256).Hash.ToLower()
        $hashLines += "$hash  $hf"
    }
}
if ($hashLines.Count -gt 0) {
    $hashLines -join "`n" | Set-Content -Path (Join-Path $UsbRoot "SHA256SUMS") -NoNewline -Encoding UTF8
    Write-Host "  SHA256SUMS generated for $($hashLines.Count) files." -ForegroundColor Gray
}

Write-Progress -Activity "Prismo USB Setup" -Completed

# --- Summary ---
Write-Host ""
Write-Host "  [########################################] 100% - Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  +============================================+" -ForegroundColor Cyan
Write-Host "  |       SETUP COMPLETED SUCCESSFULLY        |" -ForegroundColor Cyan
Write-Host "  +============================================+" -ForegroundColor Cyan
Write-Host ""
Write-Host "USB drive structure ${UsbDrive}:\" -ForegroundColor Yellow
Write-Host "  runtime\         - Portable Node.js (Win + Linux + macOS)"
Write-Host "  runtime\git\     - Git Portable (for Windows without Git)"
Write-Host "  engine\          - AI engine + Lighthouse + pa11y"
Write-Host "  config\          - Configuration and credentials"
Write-Host "  toolkit\         - Diagnostic prompts, scripts, and reports"
Write-Host ""
Write-Host "[NOTE] macOS: tar.gz files will be extracted by launch.sh on first run." -ForegroundColor Gray
Write-Host ""
Write-Host "To use:" -ForegroundColor Yellow
Write-Host "  Windows:  Double-click launch.bat (or launch.ps1)"
Write-Host "  Linux:    bash launch.sh"
Write-Host "  macOS:    bash launch.sh"
Write-Host ""
Write-Host "IMPORTANT: The USB drive contains your credentials." -ForegroundColor Red
Write-Host "Consider encrypting it with BitLocker or VeraCrypt." -ForegroundColor Red
