# Get previous sign in success and failure events from domains

# Find DC list from Active Directory
$DCs = Get-ADDomainController -Filter *

# Define time for report (default is 1 day)
$startDate = (get-date).AddDays(-1)

$incre = 0
$incre2 = 0
# Store successful logon events from security logs with the specified dates and workstation/IP in an array
foreach ($DC in $DCs){
$slogonevents = Get-Eventlog -LogName Security

# Crawl through events; print all logon history with type, date/time, status, account name, computer and IP address if user logged on remotely

  foreach ($e in $slogonevents){
    # Logon Successful Events
    # Local (Logon Type 2)
    if (($e.EventID -eq 4624 ) ){
      write-host "Type: Local Logon`tDate: "$e.TimeGenerated "`tStatus: Success`tUser: "$e.ReplacementStrings[5] "`tWorkstation: "$e.ReplacementStrings[11]
$global:incre++
    }
    if (($e.EventID -eq 4625 ) ){
      write-host "Type: Local Logon`tDate: "$e.TimeGenerated "`tStatus: Failure`tUser: "$e.ReplacementStrings[5] "`tWorkstation: "$e.ReplacementStrings[11]
$global:incre2++
    }
    }}

Write-host "Total Successful Logons: $incre"
Write-host "Total Failed Logons: $incre2"