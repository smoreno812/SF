

Start-Transcript -Path C:\Deploy.Log

Write-Host "Setup WinRM for $RemoteHostName"

Write-Host "Enable HTTP in WinRM"
$WinRMUnEncrypt = "@{AllowUnencrypted=`"true`"}"
winrm set winrm/config/service $WinRMUnEncrypt

Write-Host "Set Basic Auth in WinRM"
$WinRmBasic = "@{Basic=`"true`"}"
winrm set winrm/config/service/Auth $WinRmBasic

Write-Host "Disable WIndows Firewall"
netsh advfirewall set allprofiles state off

Stop-Transcript
