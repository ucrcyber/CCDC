#sadness
Get-LocalUser | findstr "True" | Out-File -FilePath .\Process.txt
$files = get-item .\Process.txt
foreach ($file in $files){(Get-Content $file) | ForEach-Object {$ -replace 'True',''}  | Out-File $file}
$content = Get-Content .\Process.txt
$content | Foreach {$.TrimEnd()} | Set-Content .\Process.txt
Write-host '' | Out-File -FilePath .\Processs.txt
$extend = Read-Host -Prompt 'Extenstion'
foreach($line in [System.IO.File]::ReadLines($files))
{
       Add-Content .\Processs.txt $line-$line$extend 
}
$files = get-item .\Processs.txt
foreach ($file in $files){(Get-Content $file) | ForEach-Object {$_ -replace '-',','}  | Out-File $file}
#(Get-Content .\Processs.txt) -join "," | Set-Content .\Processs.txt
Rename-Item .\Processs.txt .\Processs.csv
Get-Content .\Processs.csv
