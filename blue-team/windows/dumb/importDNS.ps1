# Move dns backup files back to System32\dns

$zones = Get-ChildItem -Path "C:\Windows\TempLogs\dns\"
foreach ($zone in $zones){
    $backuppath = "C:\Windows\TempLogs\dns\" + $zone
    $destination = "C:\Windows\System32\dns\" + $zone
    $zonename = $zone -replace ".bak",".dns"
    Write-Host "Importing zone" $zonename
    Copy-Item $backuppath $destination
    Rename-Item $destination $zonename
}