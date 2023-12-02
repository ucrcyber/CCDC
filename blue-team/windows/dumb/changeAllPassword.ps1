# Changes all domain user passwords to a template password

Import-module activedirectory

# Disable password complexity

secedit /export /cfg C:\securityPolicy.cfg
(Get-Content C:\securityPolicy.cfg).replace("PasswordComplexity = 1","PasswordComplexity = 0") | Out-File C:\securityPolicy.cfg
secedit /configure /db C:\windows\security\local.sdb /cfg C:\securityPolicy.cfg /areas SECURITYPOLICY
rm -force C:\securityPolicy.cfg -confirm:$false

$template = read-host "Enter template password postfix"

foreach ($user in (Get-ADUser -Filter *)){
    $newPassword = $user.samaccountname + $template
    $user | Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) -Reset
    $user | Set-ADUser -ChangePasswordAtLogon $true
    Write-Host "Changed password for user" $user.samaccountname
}

# Enable password complexity

secedit /export /cfg C:\securityPolicy.cfg
(Get-Content C:\securityPolicy.cfg).replace("PasswordComplexity = 0","PasswordComplexity = 1") | Out-File C:\securityPolicy.cfg
secedit /configure /db C:\windows\security\local.sdb /cfg C:\securityPolicy.cfg /areas SECURITYPOLICY
rm -force C:\securityPolicy.cfg -confirm:$false
