# Get list of users and admins

# Make TempLogs directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs")){
    New-Item -Path "C:\Windows\TempLogs" -ItemType Directory
}

# Make userlist directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs\userlist")){
    New-Item -Path "C:\Windows\TempLogs\userlist" -ItemType Directory
}

$admins = Get-LocalGroupMember -Group "Administrators"
$output = "C:\Windows\TempLogs\userlist\admins.txt"
$output2 = "C:\Windows\TempLogs\userlist\users.txt"
Clear-Content $output
Clear-Content $output2
foreach ($admin in $admins){
	Add-Content $output $admin
}
Get-Content $output
notepad.exe $output


$users = (-Split ((Out-String -InputObject (net user)) -replace "The command completed successfully\.","" -replace "-*","" -replace "User accounts .*",""))
foreach ($user in $users){
	# Write-Output $user
	Add-Content $output2 $user
}
Get-Content $output2
notepad.exe $output2
