function Invoke-Homebridge {
    [cmdletBinding()]
    param(
        [Array] $Arguments,
        [scriptblock] $Get,
        [scriptblock] $SetOn,
        [scriptblock] $SetOff,
        [string] $LogPath
    )
    $Command = $($Arguments -join ' ')
    $Action = $Arguments[0] # Get or Set
    $MatchRegex = [Regex]::Matches(($Arguments -join " "), "([`"'])(?:(?=(\\?))\2.)*?\1")
    $Options = $MatchRegex.Value # 'Computer Locked' 'On' 'true'

    Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Executing: ", $Command
    if ($Action -eq 'Get') {
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action
        $Output = Invoke-AsCurrentUser -ScriptBlock $Get #-DebugOutput #-NoWait
        $Output
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action, ", Output: ", $Output
        Exit 0
    } elseif ($Action -eq 'Set') {
        Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action
        if ($Options[1] -eq "'On'") {
            Write-ToLog -LogFile $LogPath -LogTime $true -Text "Invoke-Homebridge - Action: ", $Action, ' ', $Options[1], ' ', $Options[2]
            if ($Options[2] -eq "'true'") {
                if ($SetOn) {
                    try {
                        $null = Invoke-AsCurrentUser -ScriptBlock $SetOn
                        $Output = 1
                    } catch {
                        $Output = 0
                    }
                }
            } else {
                if ($SetOff) {
                    try {
                        $null = Invoke-AsCurrentUser -ScriptBlock $SetOff
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