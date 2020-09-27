function Invoke-AsCurrentUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [Parameter()][string]$UserName,
        [Parameter()][switch]$Visible,
        [Parameter()][switch]$NoWait,
        [Parameter()][switch]$DebugOutput
    )
    if (-not ("RunAs.ProcessExtensions" -as [type])) {
        $SourceRunAs = Get-Content -Path $PSScriptRoot\RunAs.cs -Raw
        Add-Type -TypeDefinition $SourceRunAs -Language CSharp
    }
    $encodedcommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptBlock))
    $privs = whoami /priv /fo csv | ConvertFrom-Csv | Where-Object { $_.'Privilege Name' -eq 'SeDelegateSessionUserImpersonatePrivilege' }
    if ($privs.State -eq "Disabled") {
        Write-Error -Message "Not running with correct privilege. You must run this script as system or have the SeDelegateSessionUserImpersonatePrivilege token."
        return
    } else {
        try {
            # Use the same PowerShell executable as the one that invoked the function
            $PowerShellPath = (Get-Process -Id $pid).Path
            $cmdLine = "`"$pwshPath`" -ExecutionPolicy Bypass -Window Normal -EncodedCommand $($encodedcommand)"
            $WorkDirectory = (Split-Path -Path $PowerShellPath -Parent)
            if ($UserName) {
                [RunAs.ProcessExtensions]::StartProcessAsUser($UserName, $PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
            } else {
                [RunAs.ProcessExtensions]::StartProcessAsCurrentUser($PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
            }
        } catch {
            Write-Error -Message "Could not execute as currently logged on user: $($_.Exception.Message)" -Exception $_.Exception
            return
        }
    }
}