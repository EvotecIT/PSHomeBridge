@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'Homebridge'
    FunctionsToExport    = @('Invoke-AsCurrentUser', 'Invoke-Homebridge', 'Update-Homebridge')
    GUID                 = '0b0ba5c5-ec85-4c2b-a718-874e55a8bc3f'
    ModuleVersion        = '0.0.1'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags = 'Homebridge'
        }
    }
    RootModule           = 'PSHomeBridge.psm1'
}