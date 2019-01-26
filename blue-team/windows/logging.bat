REM Enable logging for both successful and failed events of all of these. This list is as given in Blue Team Field Manual
auditpol /set /subcatergory: "Detailed File Share" /success:enable /failure:enable
auditpol /set /subcatergory: "File System" /success:enable /failure:enable
auditpol /set /subcatergory: "Security System Extension" /success:enable /failure:enable
auditpol /set /subcatergory: "System Integrity" /success:enable /failure:enable
auditpol /set /subcatergory: "Security State Change" /success:enable /failure:enable
auditpol /set /subcatergory: "Other System Events" /success:enable /failure:enable
auditpol /set /subcatergory: "System Integrity" /success:enable /failure:enable
auditpol /set /subcatergory: "Logon" /success:enable /failure:enable
auditpol /set /subcatergory: "Logoff" /success:enable /failure:enable
auditpol /set /subcatergory: "Account Lockout" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Logon/Logoff Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Network Policy Server" /success:enable /failure:enable
auditpol /set /subcatergory: "Registry" /success:enable /failure:enable
auditpol /set /subcatergory: "SAM" /success:enable /failure:enable
auditpol /set /subcatergory: "Certification Services" /success:enable /failure:enable
auditpol /set /subcatergory: "Application Generated" /success:enable /failure:enable
auditpol /set /subcatergory: "Handle Manipulation" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Packet Drop" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Connection" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Object Access Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Detailed File Share" /success:enable /failure:enable
auditpol /set /subcatergory: "Sensitive Privilege" /success:enable /failure:enable
auditpol /set /subcatergory: "Non Sensitive Privilege" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Privilege Use Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Process Termination" /success:enable /failure:enable
auditpol /set /subcatergory: "DPAPI Activity" /success:enable /failure:enable
auditpol /set /subcatergory: "RPC Activity" /success:enable /failure:enable
auditpol /set /subcatergory: "Process Creation" /success:enable /failure:enable
auditpol /set /subcatergory: "Audit Policy Change" /success:enable /failure:enable
auditpol /set /subcatergory: "Authentication Policy Change" /success:enable /failure:enable
auditpol /set /subcatergory: "MPSSVC Rule-Level Policy" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Policy" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Policy Change Events" /success:enable /failure:enable
auditpol /set /subcatergory: "User Account Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Computer Account Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Security Group Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Distribution Group" /success:enable /failure:enable
auditpol /set /subcatergory: "Application Group Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Account Management Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Changes" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Replications" /success:enable /failure:enable
auditpol /set /subcatergory: "Detailed Directory Service Replications" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Access" /success:enable /failure:enable
auditpol /set /subcatergory: "Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Account Logon Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcatergory: "Credential Validation" /success:enable /failure:enable