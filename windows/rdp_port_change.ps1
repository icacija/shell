Write-host "Specify the number of your new RDP port: " -ForegroundColor Yellow -NoNewline;$RDPPort = Read-Host
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-TCP\" -Name PortNumber -Value $RDPPort
New-NetFirewallRule -DisplayName "New RDP Port $RDPPort" -Direction Inbound –LocalPort $RDPPort -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "New RDP Port $RDPPort" -Direction Inbound –LocalPort $RDPPort -Protocol UDP -Action Allow
Restart-Service termservice -force
Write-host "The number of the RDP port has been changed to $RDPPort " -ForegroundColor Magenta
