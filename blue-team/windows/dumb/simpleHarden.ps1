# Simple hardening

# Make TempLogs directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs")){
    New-Item -Path "C:\Windows\TempLogs" -ItemType Directory
}

# Make userlist directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs\userlist")){
    New-Item -Path "C:\Windows\TempLogs\userlist" -ItemType Directory
}

disable-windowsoptionalfeature -online -featureName rasrip
disable-windowsoptionalfeature -online -featureName WindowsMediaPlayer
disable-windowsoptionalfeature -online -featureName SimpleTCP
disable-windowsoptionalfeature -online -featureName SNMP
disable-windowsoptionalfeature -online -featureName TelnetClient
disable-windowsoptionalfeature -online -featureName SMB1Protocol
$stopservices = @(
"Spooler"
"iprip"
"SNMPTRAP"
"SSDPSRV"
"TapiSrv"
"telnet"
"lfsvc"
"MapsBroker"
"NetTcpPortSharing"
"XblAuthManager"
"XblGameSave"
"XboxNetApiSvc"
"RpcLocator"
)
foreach ($service in $stopservices) {
    Write-Output "Trying to disable $service"
    Get-Service -Name $service | Set-Service -StartupType Disabled
    Stop-Service -Force $service
}
$startservices = @(
"WSearch"
"MpsSvc"
"EventLog"
"Wuauserv"
"WinDefend"
"WdNisSvc"
)
foreach ($service in $startservices) {
    Write-Output "Trying to enable $service"
    Set-Service $service -StartupType Automatic
    Start-Service $service
}

Set-ADUser -Identity "tseug" -PasswordNeverExpires $true -CannotChangePassword $true -ChangePasswordAtLogon $false -AllowReversiblePasswordEncryption $false
Disable-ADACcount -Identity "tseug"
Set-ADUser -Identity "nimda" -PasswordNeverExpires $true -CannotChangePassword $true -ChangePasswordAtLogon $false -AllowReversiblePasswordEncryption $false
Disable-ADACcount -Identity "nimda"
Set-ADUser -Identity "DefaultAccount" -PasswordNeverExpires $true -CannotChangePassword $true -ChangePasswordAtLogon $false -AllowReversiblePasswordEncryption $false
Disable-ADACcount -Identity "DefaultAccount"

$groups = ""
# Get all groups and members of each group
foreach ($group in (Get-ADGroup -Filter *)){
    $groups += $group.Name + ":`n"
    foreach ($member in (Get-ADGroupMember -Identity $group.Name)){
        $groups += $member.Name + "`n"
    }
    $groups += "`n"
}
$output = "C:\Windows\TempLogs\userlist\groups.txt"
Clear-Content $output
Add-Content $output $groups
Get-Content $output
notepad.exe $output


NetSh Advfirewall set allprofiles state on
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True 
auditpol /set /category:* /success:enable /failure:enable
Set-MpPreference -DisableRealtimeMonitoring $false

# Get all users from AD and export to CSV file
Get-ADUser -Filter * | Export-Csv -Path domainUsers.txt -NoTypeInformation