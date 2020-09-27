Import-Module .\PSHomeBridge.psd1 -Force

$Test = Invoke-Expression "pwsh -outputformat XML -c Get-Date"
$Test