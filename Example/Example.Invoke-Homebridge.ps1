Import-Module .\PSHomeBridge.psd1 -Force

Invoke-Homebridge -Arguments $args -Get {
    try {
        $null = Get-Process -ProcessName logonui -ErrorAction Stop
        $false
    } catch {
        $true
    }
} -SetOff {
    try {
        rundll32.exe user32.dll, LockWorkStation
        $false
    } catch {
        $true
    }
} #-LogPath $PSScriptRoot\Log.txt