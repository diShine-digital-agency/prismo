<#
.SYNOPSIS
    Prismo — Windows Data Collection Script
    Part of Prismo AI Consulting Toolkit by diShine Digital Agency
    https://dishine.it

.DESCRIPTION
    Collects comprehensive Windows system information for offline analysis:
      - OS info, hardware specs, uptime
      - Disk space and volumes
      - Service states and critical service health
      - Event log errors (last 24 hours)
      - Network configuration and listening ports
      - Recent Windows updates
      - Top processes by memory usage
      - Failed scheduled tasks
      - Firewall profile status
      - Local user accounts

    Uses CimInstance with WmiObject fallback for older Windows versions.
    Saves output to a structured text file.

.PARAMETER OutputDir
    Directory where the report file will be saved (default: script directory)
#>
param(
    [string]$OutputDir = $PSScriptRoot
)

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
function Get-CimOrWmi {
    param([string]$ClassName)
    try {
        Get-CimInstance -ClassName $ClassName -ErrorAction Stop
    } catch {
        Get-WmiObject -Class $ClassName -ErrorAction SilentlyContinue
    }
}

function Write-Section {
    param([string]$Title)
    $sep = "=" * 70
    $script:report += "`n$sep`n  $Title`n$sep`n"
}

function Write-Line {
    param([string]$Text)
    $script:report += "$Text`n"
}

# ------------------------------------------------------------
# Init
# ------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$hostname  = $env:COMPUTERNAME
$outFile   = Join-Path $OutputDir "prismo_collect_win_${hostname}_${timestamp}.txt"
$script:report = ""

Write-Section "PRISMO WINDOWS DATA COLLECTION"
Write-Line "Hostname   : $hostname"
Write-Line "Collected  : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Line "Script     : Prismo AI Consulting Toolkit — diShine Digital Agency"

# ------------------------------------------------------------
# 1. OS Information
# ------------------------------------------------------------
Write-Section "OPERATING SYSTEM"
$os = Get-CimOrWmi Win32_OperatingSystem
Write-Line "Name       : $($os.Caption)"
Write-Line "Version    : $($os.Version)"
Write-Line "Build      : $($os.BuildNumber)"
Write-Line "Arch       : $($os.OSArchitecture)"
Write-Line "Install    : $($os.InstallDate)"
Write-Line "Last Boot  : $($os.LastBootUpTime)"

# Uptime
try {
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Line "Uptime     : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
} catch {
    Write-Line "Uptime     : (unable to calculate)"
}

# ------------------------------------------------------------
# 2. Hardware
# ------------------------------------------------------------
Write-Section "HARDWARE"
$cs = Get-CimOrWmi Win32_ComputerSystem
Write-Line "Manufacturer : $($cs.Manufacturer)"
Write-Line "Model        : $($cs.Model)"
Write-Line "Total RAM    : $([math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB"
Write-Line "Processors   : $($cs.NumberOfProcessors) socket(s), $($cs.NumberOfLogicalProcessors) logical"

$cpu = Get-CimOrWmi Win32_Processor | Select-Object -First 1
Write-Line "CPU          : $($cpu.Name)"
Write-Line "Cores        : $($cpu.NumberOfCores)"
Write-Line "Max Clock    : $($cpu.MaxClockSpeed) MHz"

# ------------------------------------------------------------
# 3. Disk Space
# ------------------------------------------------------------
Write-Section "DISK SPACE"
$disks = Get-CimOrWmi Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
foreach ($d in $disks) {
    $totalGB = [math]::Round($d.Size / 1GB, 2)
    $freeGB  = [math]::Round($d.FreeSpace / 1GB, 2)
    $usedPct = if ($d.Size -gt 0) { [math]::Round((1 - $d.FreeSpace / $d.Size) * 100, 1) } else { 0 }
    Write-Line "$($d.DeviceID)  Total: ${totalGB} GB  Free: ${freeGB} GB  Used: ${usedPct}%"
}

# ------------------------------------------------------------
# 4. Service States
# ------------------------------------------------------------
Write-Section "SERVICE STATES (Stopped Auto-Start Services)"
$stoppedAuto = Get-CimOrWmi Win32_Service | Where-Object {
    $_.StartMode -eq 'Auto' -and $_.State -ne 'Running'
}
if ($stoppedAuto) {
    foreach ($s in $stoppedAuto) {
        Write-Line "  [STOPPED] $($s.Name) — $($s.DisplayName)"
    }
} else {
    Write-Line "  All auto-start services are running."
}

# ------------------------------------------------------------
# 5. Critical Services Check
# ------------------------------------------------------------
Write-Section "CRITICAL SERVICES"
$criticalServices = @(
    'Winmgmt', 'wuauserv', 'WinDefend', 'Spooler',
    'EventLog', 'MSSQLSERVER', 'W3SVC', 'Dhcp', 'Dnscache',
    'LanmanServer', 'LanmanWorkstation', 'PlugPlay', 'RpcSs'
)
foreach ($svcName in $criticalServices) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc) {
        $status = if ($svc.Status -eq 'Running') { "[OK]" } else { "[!!]" }
        Write-Line "  $status $svcName — $($svc.Status)"
    }
}

# ------------------------------------------------------------
# 6. Event Log Errors (Last 24 Hours)
# ------------------------------------------------------------
Write-Section "EVENT LOG ERRORS (Last 24 Hours)"
$cutoff = (Get-Date).AddHours(-24)
try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'System','Application'
        Level     = 2  # Error
        StartTime = $cutoff
    } -MaxEvents 50 -ErrorAction Stop
    foreach ($evt in $events) {
        Write-Line "  [$($evt.TimeCreated.ToString('yyyy-MM-dd HH:mm'))] [$($evt.LogName)] $($evt.ProviderName): $($evt.Message.Substring(0, [Math]::Min(120, $evt.Message.Length)))..."
    }
} catch {
    Write-Line "  No errors found or insufficient permissions."
}

# ------------------------------------------------------------
# 7. Network Configuration
# ------------------------------------------------------------
Write-Section "NETWORK CONFIGURATION"
try {
    $adapters = Get-NetIPConfiguration -ErrorAction Stop
    foreach ($a in $adapters) {
        Write-Line "  Interface : $($a.InterfaceAlias)"
        Write-Line "    IPv4    : $($a.IPv4Address.IPAddress)"
        Write-Line "    Gateway : $($a.IPv4DefaultGateway.NextHop)"
        Write-Line "    DNS     : $($a.DNSServer.ServerAddresses -join ', ')"
        Write-Line ""
    }
} catch {
    ipconfig /all | ForEach-Object { Write-Line "  $_" }
}

# ------------------------------------------------------------
# 8. Listening Ports
# ------------------------------------------------------------
Write-Section "LISTENING PORTS (TCP)"
try {
    $listeners = Get-NetTCPConnection -State Listen -ErrorAction Stop |
        Sort-Object LocalPort |
        Select-Object LocalAddress, LocalPort, OwningProcess -Unique
    foreach ($l in $listeners) {
        $procName = (Get-Process -Id $l.OwningProcess -ErrorAction SilentlyContinue).ProcessName
        Write-Line "  $($l.LocalAddress):$($l.LocalPort)  PID:$($l.OwningProcess)  ($procName)"
    }
} catch {
    netstat -ano | Select-String "LISTENING" | ForEach-Object { Write-Line "  $_" }
}

# ------------------------------------------------------------
# 9. Recent Updates
# ------------------------------------------------------------
Write-Section "RECENT WINDOWS UPDATES (Last 10)"
try {
    $updates = Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object -First 10
    foreach ($u in $updates) {
        Write-Line "  $($u.HotFixID)  $($u.InstalledOn.ToString('yyyy-MM-dd'))  $($u.Description)"
    }
} catch {
    Write-Line "  Unable to retrieve update history."
}

# ------------------------------------------------------------
# 10. Top Processes by Memory
# ------------------------------------------------------------
Write-Section "TOP 15 PROCESSES BY MEMORY"
$procs = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 15
foreach ($p in $procs) {
    $memMB = [math]::Round($p.WorkingSet64 / 1MB, 1)
    Write-Line "  $($p.ProcessName.PadRight(30)) $($memMB.ToString().PadLeft(8)) MB  PID:$($p.Id)"
}

# ------------------------------------------------------------
# 11. Failed Scheduled Tasks
# ------------------------------------------------------------
Write-Section "FAILED SCHEDULED TASKS"
try {
    $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object { $_.State -ne 'Disabled' }
    $failed = foreach ($t in $tasks) {
        $info = Get-ScheduledTaskInfo -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction SilentlyContinue
        if ($info -and $info.LastTaskResult -ne 0 -and $info.LastTaskResult -ne 267009) {
            [PSCustomObject]@{
                Name   = $t.TaskName
                Path   = $t.TaskPath
                Result = $info.LastTaskResult
                LastRun = $info.LastRunTime
            }
        }
    }
    if ($failed) {
        foreach ($f in $failed | Select-Object -First 20) {
            Write-Line "  $($f.Path)$($f.Name)  Result: $($f.Result)  Last: $($f.LastRun)"
        }
    } else {
        Write-Line "  No failed scheduled tasks detected."
    }
} catch {
    Write-Line "  Unable to query scheduled tasks."
}

# ------------------------------------------------------------
# 12. Firewall Profiles
# ------------------------------------------------------------
Write-Section "FIREWALL PROFILES"
try {
    $fw = Get-NetFirewallProfile -ErrorAction Stop
    foreach ($profile in $fw) {
        $status = if ($profile.Enabled) { "ENABLED" } else { "DISABLED" }
        Write-Line "  $($profile.Name.PadRight(15)) $status  (Inbound: $($profile.DefaultInboundAction), Outbound: $($profile.DefaultOutboundAction))"
    }
} catch {
    netsh advfirewall show allprofiles state | ForEach-Object { Write-Line "  $_" }
}

# ------------------------------------------------------------
# 13. Local Users
# ------------------------------------------------------------
Write-Section "LOCAL USER ACCOUNTS"
try {
    $users = Get-LocalUser -ErrorAction Stop
    foreach ($u in $users) {
        $status = if ($u.Enabled) { "Enabled" } else { "Disabled" }
        Write-Line "  $($u.Name.PadRight(25)) $status  LastLogon: $($u.LastLogon)"
    }
} catch {
    net user | ForEach-Object { Write-Line "  $_" }
}

# ------------------------------------------------------------
# Save Report
# ------------------------------------------------------------
Write-Section "END OF REPORT"
$script:report | Out-File -FilePath $outFile -Encoding UTF8
Write-Host "[Prismo] Report saved to: $outFile" -ForegroundColor Green
