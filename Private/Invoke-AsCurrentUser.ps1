function Invoke-AsCurrentUser {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    By default it hides all errors as errors tend to impact how HomeBridge works when things fail. Therefore if you want to see errors use ErrorAction Stop

    .PARAMETER ScriptBlock
    Parameter description

    .PARAMETER UserName
    Parameter description

    .PARAMETER Visible
    Parameter description

    .PARAMETER NoWait
    Parameter description

    .PARAMETER DebugOutput
    Parameter description

    .PARAMETER AsXML
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [Parameter()][string]$UserName,
        [Parameter()][switch]$Visible,
        [Parameter()][switch]$NoWait,
        [Parameter()][switch]$DebugOutput,
        [switch] $AsXML
    )
    if (-not ("RunAs.ProcessExtensions" -as [type])) {
        $SourceRunAs = Get-Content -Path $PSScriptRoot\RunAs.cs -Raw
        Add-Type -TypeDefinition $SourceRunAs -Language CSharp
    }
    $encodedcommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptBlock))
    $privs = whoami /priv /fo csv | ConvertFrom-Csv | Where-Object { $_.'Privilege Name' -eq 'SeDelegateSessionUserImpersonatePrivilege' }
    if ($privs.State -eq "Disabled") {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            Write-Error -Message "Not running with correct privilege. You must run this script as system or have the SeDelegateSessionUserImpersonatePrivilege token."
            return
        } else {
            return $false
        }
    } else {
        try {
            # Use the same PowerShell executable as the one that invoked the function
            $PowerShellPath = (Get-Process -Id $pid).Path
            if ($AsXML) {
                $cmdLine = "`"$pwshPath`" -ExecutionPolicy Bypass -Window Normal -EncodedCommand $($encodedcommand) -OutputFormat XML"
            } else {
                $cmdLine = "`"$pwshPath`" -ExecutionPolicy Bypass -Window Normal -EncodedCommand $($encodedcommand)"
            }
            $WorkDirectory = (Split-Path -Path $PowerShellPath -Parent)
            if ($AsXML) {
                # Not working correctly, so don't use
                if ($UserName) {
                    [RunAs.ProcessExtensions]::StartProcessAsUserXml($UserName, $PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
                } else {
                    [RunAs.ProcessExtensions]::StartProcessAsCurrentUserXml($PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
                }
            } else {
                if ($UserName) {
                    [RunAs.ProcessExtensions]::StartProcessAsUser($UserName, $PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
                } else {
                    [RunAs.ProcessExtensions]::StartProcessAsCurrentUser($PowerShellPath, $cmdLine, $WorkDirectory, $Visible.IsPresent, $NoWait.IsPresent, $DebugOutput.IsPresent)
                }
            }
        } catch {
            if ($PSBoundParameters.ErrorAction -eq 'Stop') {
                Write-Error -Message "Could not execute as currently logged on user: $($_.Exception.Message)" -Exception $_.Exception
                return
            } else {
                return $false
            }
        }
    }
}