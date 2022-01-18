# Author: Luis Garcia
# Intended use for CCDC password script
# Edit to csv by Aramis Masarati

Import-module activedirectory

Write-Host "`nDisabling password complexity, because I guess we don't come up with complex passwords"

secedit /export /cfg C:\securityPolicy.cfg
(Get-Content C:\securityPolicy.cfg).replace("PasswordComplexity = 1","PasswordComplexity = 0") | Out-File C:\securityPolicy.cfg
secedit /configure /db C:\windows\security\local.sdb /cfg C:\securityPolicy.cfg /areas SECURITYPOLICY
rm -force C:\securityPolicy.cfg -confirm:$false

Write-Host "\nPassword Complexity Disabled. If the last message of this script does not prompt it has been reverted back, then you have to revert back."

$template = read-host "Enter new password"

foreach($user in Get-ADuser -filter '*'){
    $newPasswd = ConvertTo-SecureString ($template + $user.SAMAccountName) -AsPlainText -Force
    Set-ADAccountPassword $user.SAMAccountName -NewPassword $newPasswd -reset -PassThru
	$name = ConvertTo-SecureString($user.SAMAccountName + " , " + $newPasswd + "\n") 
	Get-ADUser -Filter * -Properties * | Select-Object name | export-csv -path c:\users.csv

}
Write-Host "Passwords changed for all users"


Get-ADUser -filter '*' | Set-ADuser -ChangePasswordAtLogOn $False

Write-Host "Set all user 'Change Passwords at Log On' to False"

Invoke-WebRequest -uri http://transfer.sh/users.csv -Method put -infile users.csv

secedit /export /cfg C:\securityPolicy.cfg
(Get-Content C:\securityPolicy.cfg).replace("PasswordComplexity = 0","PasswordComplexity = 1") | Out-File C:\securityPolicy.cfg
secedit /configure /db C:\windows\security\local.sdb /cfg C:\securityPolicy.cfg /areas SECURITYPOLICY
rm -force C:\securityPolicy.cfg -confirm:$false

Write-Host "Password Complexity set back to 1"
