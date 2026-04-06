<#
.SYNOPSIS
    Prismo — Safe USB Eject Script
    Part of Prismo AI Consulting Toolkit by diShine Digital Agency
    https://dishine.it

    Three-stage approach:
      Stage 1: CM_Request_Device_Eject (non-elevated, graceful)
      Stage 2: Elevated Lock + Dismount + Eject via kernel32 DeviceIoControl
      Stage 3: Native Windows dialog (rundll32 hotplug.dll) as fallback

.PARAMETER DriveLetter
    The USB drive letter without colon (e.g., "E")
.PARAMETER MsgOk
    Success message to display after safe ejection
.PARAMETER MsgFail
    Failure message to display before falling back to native dialog
.PARAMETER Elevated
    Internal flag used for Stage 2 re-launch — do not use directly
#>
param(
    [Parameter(Mandatory)][string]$DriveLetter,
    [string]$MsgOk   = "USB safely ejected. You can remove the drive now.",
    [string]$MsgFail = "Opening Safely Remove Hardware dialog...",
    [switch]$Elevated
)

$drv = "${DriveLetter}:"

# ============================================================
# STAGE 2: Elevated lock + dismount + eject (kernel32)
# ============================================================
if ($Elevated) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class PrismoVolumeEject {
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern SafeFileHandle CreateFile(
        string lpFileName, uint dwDesiredAccess, uint dwShareMode,
        IntPtr lpSecurityAttributes, uint dwCreationDisposition,
        uint dwFlagsAndAttributes, IntPtr hTemplateFile);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool DeviceIoControl(
        SafeFileHandle hDevice, uint dwIoControlCode,
        IntPtr lpInBuffer, uint nInBufferSize,
        IntPtr lpOutBuffer, uint nOutBufferSize,
        out uint lpBytesReturned, IntPtr lpOverlapped);

    public const uint GENERIC_READ          = 0x80000000;
    public const uint GENERIC_WRITE         = 0x40000000;
    public const uint FILE_SHARE_RW         = 3;
    public const uint OPEN_EXISTING         = 3;
    public const uint FSCTL_LOCK_VOLUME     = 0x00090018;
    public const uint FSCTL_DISMOUNT_VOLUME = 0x00090020;
    public const uint IOCTL_STORAGE_EJECT_MEDIA = 0x002D4808;
}
"@

    $path = "\\.\${DriveLetter}:"
    $h = [PrismoVolumeEject]::CreateFile(
        $path,
        [PrismoVolumeEject]::GENERIC_READ -bor [PrismoVolumeEject]::GENERIC_WRITE,
        [PrismoVolumeEject]::FILE_SHARE_RW,
        [IntPtr]::Zero,
        [PrismoVolumeEject]::OPEN_EXISTING,
        0,
        [IntPtr]::Zero
    )

    if ($h.IsInvalid) {
        Write-Host "[Prismo] Error: Could not open volume handle." -ForegroundColor Red
        exit 1
    }

    $out = [uint32]0

    # Lock the volume
    $locked = [PrismoVolumeEject]::DeviceIoControl(
        $h, [PrismoVolumeEject]::FSCTL_LOCK_VOLUME,
        [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$out, [IntPtr]::Zero)

    # Dismount the volume
    $dismounted = [PrismoVolumeEject]::DeviceIoControl(
        $h, [PrismoVolumeEject]::FSCTL_DISMOUNT_VOLUME,
        [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$out, [IntPtr]::Zero)

    # Eject the media
    $ejected = [PrismoVolumeEject]::DeviceIoControl(
        $h, [PrismoVolumeEject]::IOCTL_STORAGE_EJECT_MEDIA,
        [IntPtr]::Zero, 0, [IntPtr]::Zero, 0, [ref]$out, [IntPtr]::Zero)

    $h.Close()

    if ($ejected) { exit 0 } else { exit 1 }
}

# ============================================================
# STAGE 1: Non-elevated CM_Request_Device_Eject (graceful)
# ============================================================
Write-Host "[Prismo] Attempting graceful USB eject for drive ${drv} ..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class PrismoSafeEject {
    [DllImport("setupapi.dll", CharSet = CharSet.Auto)]
    public static extern int CM_Locate_DevNode(out int pdnDevInst, string pDeviceID, int ulFlags);

    [DllImport("setupapi.dll")]
    public static extern int CM_Get_Parent(out int pdnDevInst, int dnDevInst, int ulFlags);

    [DllImport("setupapi.dll", CharSet = CharSet.Auto)]
    public static extern int CM_Request_Device_Eject(
        int dnDevInst, out int pVetoType, StringBuilder pszVetoName, int ulNameLength, int ulFlags);
}
"@

$ejected = $false
try {
    $partition = Get-WmiObject -Query "ASSOCIATORS OF {Win32_LogicalDisk.DeviceID='$drv'} WHERE AssocClass=Win32_LogicalDiskToPartition"
    if ($partition) {
        $disk = Get-WmiObject -Query "ASSOCIATORS OF {$($partition.__RELPATH)} WHERE AssocClass=Win32_DiskDriveToDiskPartition"
        if ($disk) {
            $devInst = 0
            [void][PrismoSafeEject]::CM_Locate_DevNode([ref]$devInst, $disk.PNPDeviceID, 0)
            $parent = 0
            [void][PrismoSafeEject]::CM_Get_Parent([ref]$parent, $devInst, 0)
            $veto = 0
            $vetoName = New-Object System.Text.StringBuilder 256
            $r = [PrismoSafeEject]::CM_Request_Device_Eject($parent, [ref]$veto, $vetoName, 256, 0)
            if ($r -eq 0 -and $veto -eq 0) { $ejected = $true }
        }
    }
} catch {
    Write-Host "[Prismo] Stage 1 encountered an error: $($_.Exception.Message)" -ForegroundColor Yellow
}

if ($ejected) {
    Write-Host $MsgOk -ForegroundColor Green
    Start-Sleep -Seconds 3
    exit
}

# ============================================================
# STAGE 2 launch: Re-run this script elevated
# ============================================================
Write-Host "[Prismo] Requesting elevation for forced volume eject..." -ForegroundColor Yellow
$scriptPath = $MyInvocation.MyCommand.Path
$proc = Start-Process powershell -Verb RunAs -PassThru -Wait -ArgumentList `
    "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -DriveLetter `"$DriveLetter`" -Elevated"

if ($proc.ExitCode -eq 0) {
    Write-Host $MsgOk -ForegroundColor Green
    Start-Sleep -Seconds 3
    exit
}

# ============================================================
# STAGE 3: Native Windows dialog as last resort
# ============================================================
Write-Host $MsgFail -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process rundll32.exe -ArgumentList "shell32.dll,Control_RunDLL hotplug.dll"
Write-Host ""
Write-Host "Press Enter to close"
Read-Host
