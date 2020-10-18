function Lock-Display {
    [cmdletBinding()]
    param(

    )
    try {
        rundll32.exe user32.dll, LockWorkStation
        $false
    } catch {
        $true
    }
}