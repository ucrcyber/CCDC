# Export DNS zones to be imported later

# Make TempLogs directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs")){
    New-Item -Path "C:\Windows\TempLogs" -ItemType Directory
}

# Make DNS directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs\dns")){
    New-Item -Path "C:\Windows\TempLogs\dns" -ItemType Directory
}

$zones = Get-DNSServerZone
foreach ($zone in $zones){
    Write-Host "Exporting zone" $zone.ZoneName
    $exportname = $zone.ZoneName + ".bak"
    Export-DnsServerZone $zone.ZoneName $exportname
    $backuppath = "C:\Windows\System32\dns\" + $exportname
    $destination = "C:\Windows\TempLogs\dns\" + $exportname
    Copy-Item $backuppath $destination
}