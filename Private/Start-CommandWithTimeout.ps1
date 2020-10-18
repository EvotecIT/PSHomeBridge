function Start-CommandWithTimeout {
    <#
    .SYNOPSIS
    Executes scriptblock and wait maximum amount of time that's defined

    .DESCRIPTION
    Long description

    .PARAMETER Command
    ScriptBlock to execute

    .PARAMETER Timeout
    Maximum time to wait for command to execute in miliseconds

    .EXAMPLE
    Start-CommandWithTimeout -Command { Start-Sleep -Second 10 } -TimeOut 12000

    .EXAMPLE
    Start-CommandWithTimeout -Command { Start-Sleep -Second 10 } -TimeOut 4000

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Command,
        [Parameter(Mandatory)][int] $Timeout
    )

    $ResultData = @{
        Success = $false
    }

    $Runspace = [runspacefactory]::CreateRunspace()
    $Runspace.Open()

    $PS = [powershell]::Create().AddScript($Command)
    $PS.Runspace = $Runspace

    $IAR = $PS.BeginInvoke()
    if ($IAR.AsyncWaitHandle.WaitOne($Timeout)) {
        $ResultData.Success = $true
        $ResultData.Data = $PS.EndInvoke($IAR)
    }
    [PSCustomObject] $ResultData
}