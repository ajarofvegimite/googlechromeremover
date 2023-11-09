# PowerShell Script to Uninstall Google Chrome and Log Actions

# Define the path to the log file
$LogPath = "C:\Temp\GoogleChromeUninstall.log"

# Function to write log with timestamp
function Write-Log {
    Param ([string]$logMessage)

    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timeStamp - $logMessage" | Out-File -FilePath $LogPath -Append
}

# Write initial log entry
Write-Log "Starting Google Chrome uninstallation script."

# Stop Chrome processes
try {
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
	Taskkill /IM Chome.exe /F
	Taskkill /IM GoogleCrashHandler.exe /F
	Taskkill /IM GoogleCrashHandler64.exe /F
	Taskkill /IM GoogleUpdate.exe /F
    Write-Log "Stopped all Chrome processes."
} catch {
    Write-Log "Error stopping Chrome processes: $_"
}

# Delete Chrome directories and write to log
$chromePaths = @(
    "$env:PROGRAMFILES\Google\Chrome",
    "$env:PROGRAMFILES (x86)\Google\Chrome",
	"$env:PROGRAMFILES\Google\Update",
	"$env:PROGRAMFILES (x86)\Google\Update"
)

foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path $path -Recurse -Force
            Write-Log "Removed Chrome directory at $path."
        } catch {
            Write-Log "Failed to remove Chrome directory at $path. Error: $_"
        }
    } else {
        Write-Log "Chrome directory at $path not found."
    }
}

# Remove desktop, start menu & common start menu shortcuts
try {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $startMenuPath = [Environment]::GetFolderPath("Programs")
    $commonStartMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
	$desktopShortcut = Join-Path $desktopPath "Google Chrome.lnk"
    $startMenuShortcut = Join-Path $startMenuPath "Google Chrome.lnk"
	$commonStartMenuShortcut = Join-Path $commonStartMenuPath "Google Chrome.lnk"

		if (Test-Path $desktopShortcut) {
        Remove-Item $desktopShortcut -Force
        Write-Log "Removed Chrome desktop shortcut."
    } else {
        Write-Log "Chrome desktop shortcut not found."
    }

    if (Test-Path $startMenuShortcut) {
        Remove-Item $startMenuShortcut -Force
        Write-Log "Removed Chrome start menu shortcut."
    } else {
        Write-Log "Chrome start menu shortcut not found."
    }
	if (Test-Path $commonStartMenuShortcut) {
		Remove-Item $commonStartMenuShortcut -Force
        Write-Log "Removed Chrome common start menu shortcut."
    } else {
        Write-Log "Chrome common start menu shortcut not found."
    }
} catch {
    Write-Log "Error removing Chrome shortcuts: $_"
}

# Clean registry entries and write to log
try {
    if (Test-Path 'HKCU:\Software\Google\Chrome') {
        Remove-Item -Path 'HKCU:\Software\Google\Chrome' -Recurse -Force
        Write-Log "Removed HKCU Chrome registry entries."
    }

    if (Test-Path 'HKLM:\SOFTWARE\Google\Chrome') {
        Remove-Item -Path 'HKLM:\SOFTWARE\Google\Chrome' -Recurse -Force
        Write-Log "Removed HKLM Chrome registry entries."
    }

    if (Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Google\Chrome') {
        Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Google\Chrome' -Recurse -Force
        Write-Log "Removed Wow6432Node Chrome registry entries."
    }

    # Remove uninstall registry key for Google Chrome (if exists)
    $uninstallPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    $chromeUninstallEntries = Get-ChildItem $uninstallPath -ErrorAction SilentlyContinue |
                              Where-Object { $_ -match 'Google Chrome' }

    foreach ($entry in $chromeUninstallEntries) {
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$entry" -Recurse -Force
        Write-Log "Removed Chrome uninstall registry entry: $entry"
    }
} catch {
    Write-Log "Error cleaning Chrome registry entries: $_"
}

# Conclude the script with a final log entry
Write-Log "Google Chrome uninstallation script completed."

