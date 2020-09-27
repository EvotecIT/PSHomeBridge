function Invoke-Homebridge {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Arguments
    Parameter description

    .PARAMETER Get
    Parameter description

    .PARAMETER SetOn
    Parameter description

    .PARAMETER SetOff
    Parameter description

    .PARAMETER LogPath
    Parameter description

    .PARAMETER UseInvokeCommand
    Uses Invoke-Command instead of Invoke-AsCurrentUser

    .PARAMETER DefaultStatus
    This sets behavior for when Homebridge action is not returning True/False but returns null or some other data. You can set it to True or False to make sure Homebridge provides proper information

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [Array] $Arguments,
        [scriptblock] $Get,
        [scriptblock] $SetOn,
        [scriptblock] $SetOff,
        [string] $LogPath,
        [switch] $UseInvokeCommand,
        [bool] $DefaultStatus = $false
    )
    $Command = $($Arguments -join ' ')
    $Action = $Arguments[0] # Get or Set
    $MatchRegex = [Regex]::Matches(($Arguments -join " "), "([`"'])(?:(?=(\\?))\2.)*?\1")
    $Options = $MatchRegex.Value # 'Computer Locked' 'On' 'true'

    Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Executing: ", $Command
    if ($Action -eq 'Get') {
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action
        if ($UseInvokeCommand) {
            $Output = Invoke-Command -ScriptBlock $Get
            $Output
        } else {
            $Overwritten = $false
            try {
                $Output = Invoke-AsCurrentUser -ScriptBlock $Get -ErrorAction SilentlyContinue #-AsXML #-DebugOutput #-NoWait
                if ($Output -notin @($true, $false)) {
                    $Output = $DefaultStatus
                    $Overwritten = $true
                } else {
                    $Output
                }
            } catch {
                $Output = $DefaultStatus
                $Overwritten = $true
            }
        }
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action, ", Output: ", $Output, ", Overwritten: $Overwritten"
        Exit 0
    } elseif ($Action -eq 'Set') {
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action
        if ($Options[1] -eq "'On'") {
            Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action, ' ', $Options[1], ' ', $Options[2]
            if ($Options[2] -eq "'true'") {
                if ($SetOn) {
                    try {
                        $null = Invoke-AsCurrentUser -ScriptBlock $SetOn -ErrorAction SilentlyContinue
                        $Output = 1
                    } catch {
                        $Output = 0
                    }
                }
            } else {
                if ($SetOff) {
                    try {
                        $null = Invoke-AsCurrentUser -ScriptBlock $SetOff -ErrorAction SilentlyContinue
                        $Output = 1
                    } catch {
                        $Output = 0
                    }
                }
            }
            $Output
            Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action, ", Output: ", $Output
            Exit 0
        } elseif ($Options[2] -eq "'Off") {
            Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Not supported(0): ", $Action, ' ', $Options[1], ' ', $Options[2]
            Write-Output "Not supported (0) $($Arguments -join ' ')"
            Exit 66
        } else {
            Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Not supported(1): ", $Action, ' ', $Options[1], ' ', $Options[2]
            Write-Output "Not supported (1) $($Arguments -join ' ')"
            Exit 66
        }
    } else {
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Not supported(2): ", $Action, ' ', $Options[1], ' ', $Options[2]
        Write-Output "Not supported (2) $($Arguments -join ' ')"
        Exit 66
    }
}