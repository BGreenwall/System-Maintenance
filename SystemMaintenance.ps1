# Script Name: SystemMaintenance.ps1
# Author: Braden G
# Date: 8/25/2024
# Description: This script performs system maintenance by clearing temporary files, emptying the recycle bin, and generating a disk space usage report.

# Parameters
$TempDirectories = @("C:\Windows\Temp", "$env:TEMP", "$env:TMP")  # List of directories to clear
$LogFile = "C:\Users\braden\Documents\MaintenanceLogs\system_maintenance.log"  # Path to log file

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp : $Message" | Out-File -FilePath $LogFile -Append
}

# Function to clear temporary files
function Clear-TempFiles {
    foreach ($TempDir in $TempDirectories) {
        if (Test-Path $TempDir) {
            Get-ChildItem -Path $TempDir -Recurse -Force | Remove-Item -Force -Recurse
            Log-Message "INFO: Cleared temporary files in $TempDir"
        } else {
            Log-Message "WARNING: Temporary directory $TempDir does not exist."
        }
    }
}

# Function to empty the recycle bin
function Empty-RecycleBin {
    try {
        (New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { $_.InvokeVerb('delete') }
        Log-Message "INFO: Emptied the recycle bin."
    } catch {
        Log-Message "ERROR: Failed to empty the recycle bin. $_"
    }
}

# Function to generate a disk space usage report
function Generate-DiskUsageReport {
    $Drives = Get-PSDrive -PSProvider FileSystem
    foreach ($Drive in $Drives) {
        $Usage = [math]::Round(($Drive.Used / $Drive.Used + $Drive.Free) * 100, 2)
        Log-Message "INFO: Disk usage on $($Drive.Name): $Usage% ($($Drive.Used) used of $($Drive.Used + $Drive.Free))"
    }
}

# Main script execution
Log-Message "INFO: System maintenance script started."

Clear-TempFiles
Empty-RecycleBin
Generate-DiskUsageReport

Log-Message "INFO: System maintenance script completed."
