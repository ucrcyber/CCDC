# Get all users from AD and export to CSV file

# Make TempLogs directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs")){
    New-Item -Path "C:\Windows\TempLogs" -ItemType Directory
}

# Make userlist directory if it doesn't exist
if (!(Test-Path -Path "C:\Windows\TempLogs\userlist")){
    New-Item -Path "C:\Windows\TempLogs\userlist" -ItemType Directory
}

Get-ADUser -Filter * | Export-Csv -Path "C:\Windows\TempLogs\userlist\domainUsers.csv" -NoTypeInformation