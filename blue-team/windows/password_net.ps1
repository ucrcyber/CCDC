# password scripting using net since Get-LocalUser is PS 5.1+

$users = (-Split ((Out-String -InputObject (net user)) -replace "The command completed successfully\.","" -replace "-*","" -replace "User accounts .*",""))
$template = Read-Host -Prompt "Template (prefix)"
$output = "12.csv"

Clear-Content $output
foreach ($user in $users){
	# Write-Output $user
	Add-Content $output $user","$template$user
	net user $user $template$user
}
Get-Content $output
notepad.exe $output