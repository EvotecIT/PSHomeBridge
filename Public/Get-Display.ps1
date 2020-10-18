function Get-Display {
    [cmdletBinding()]
    param(

    )
    try {
        $null = Get-Process -ProcessName logonui -ErrorAction Stop
        $false
    } catch {
        $true
    }
}