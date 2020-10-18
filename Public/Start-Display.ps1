Function Start-Display {
    [CmdletBinding(HelpURI = 'https://gallery.technet.microsoft.com/Turn-the-Display-On-and-Off-3414d706')]
    Param(

    )
    $ScriptBlock = {
        Add-Type -Namespace Win32API -Name Message -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(
        int hWnd,
        UInt32 Msg,
        int wParam,
        int lParam
    );
'@
        $msg = @{
            HWND_Broadcast  = 0xFFFF
            WM_SysCommand   = 0x0112
            SC_MonitorPower = 0xF170
            PowerOn         = -1
            PowerOff        = 2
        }
        [Win32API.Message]::SendMessage($msg.HWND_Broadcast, $msg.WM_SysCommand, $msg.SC_MonitorPower, $msg.PowerOn)
    }
    $null = Start-CommandWithTimeout -Command $ScriptBlock -Timeout 400
    $true
}
