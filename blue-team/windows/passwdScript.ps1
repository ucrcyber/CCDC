Import-module activedirectory
$newPasswd = read-host "Enter new password" -AsSecureString
Get-ADuser -filter '*' | Set-ADAccountPassword -NewPassword $newPasswd -reset -PassThru
<#
 Get-ADuser -filter "enable -eq 'false'" means it will filter and select the users that are disabled
 Get-ADuser -filter "enable -eq 'true'"" means it will filter and select the users that are enabled
 Get-ADuser -searchBase "ou=orginizationalUnit dc=domainController dc=domainExtension" both DCs make up domainController.domainExtension
 enable-adaccount <user>
 disable-adaccount <user>
 #>
Echo "Passwords changed for all users"
Get-ADUser -filter '*' | Set-ADuser -ChangePasswordAtLogOn $False
Echo "Set all user 'Change Passwords at Log On' to False"
