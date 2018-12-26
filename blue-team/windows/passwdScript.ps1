{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf100
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 Import-module activedirectory\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf0 $newPasswd = read-host \'91Enter new password\'92 -AsSecureString\
Get-ADuser -filter \'91*\'92 | Set-ADAccountPassword -NewPassword $newPasswd -reset -PassThru\
<#\
 Get-ADuser -filter \'93enable -eq \'91false\'92\'94 means it will filter and select the users that are disabled\
 Get-ADuser -filter \'93enable -eq \'92true\'92\'94 means it will filter and select the users that are enabled\
 Get-ADuser -searchBase \'93ou=orginizationalUnit dc=domainController dc=domainExtension\'94 both DCs make up domainController.domainExtension\
 enable-adaccount <user>\
 disable-adaccount <user>\
 #>\
Echo \'93Passwords changed for all users\'94\
Get-ADUser -filter \'91*\'92 | Set-ADuser -ChangePasswordAtLogOn $False\
Echo \'93Set all user \'91Change Passwords at Log On\'92 to False\'94}