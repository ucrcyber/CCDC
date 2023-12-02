# Backup common folders

# Make TempLogs directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs")){
    New-Item -Path "C:\Windows\TempLogs" -ItemType Directory
}

# Make backup directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs\backup")){
    New-Item -Path "C:\Windows\TempLogs\backup" -ItemType Directory
}

# Try to save http files
try{
    Copy-Item -Path "C:\inetpub\wwwroot\*" -Destination "C:\Windows\TempLogs\backup\"
}
catch{
    Write-Host "Could not save http files"
}

# Try to save ftp files
try{
    Copy-Item -Path "C:\inetpub\ftproot\*" -Destination "C:\Windows\TempLogs\backup\"
}
catch{
    Write-Host "Could not save ftp files"
}

# Try to save dns files
try{
    Copy-Item -Path "C:\Windows\System32\dns\*" -Destination "C:\Windows\TempLogs\backup\"
}
catch{
    Write-Host "Could not save dns files"
}

# Try to save dhcp files
try{
    Copy-Item -Path "C:\Windows\System32\dhcp\*" -Destination "C:\Windows\TempLogs\backup\"
}
catch{
    Write-Host "Could not save dhcp files"
}

# Try to save iis files
try{
    Copy-Item -Path "C:\Windows\System32\inetsrv\*" -Destination "C:\Windows\TempLogs\backup\"
}
catch{
    Write-Host "Could not save iis files"
}