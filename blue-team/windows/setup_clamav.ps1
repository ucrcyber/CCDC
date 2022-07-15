wget http://www.clamav.net/downloads/production/clamav-0.105.0.win.x64.msi -outfile clamav.msi
.\clamav.msi /quiet

cp "C:\Program Files\ClamAV\conf_examples\clamd.conf.sample" "C:\Program Files\ClamAV\clamd.conf"
cp "C:\Program Files\ClamAV\conf_examples\freshclam.conf.sample" "C:\Program Files\ClamAV\freshclam.conf"

(Get-Content "C:\Program Files\ClamAV\clamd.conf") -replace '^Example$','' | Set-Content "C:\Program Files\ClamAV\clamd.conf"
(Get-Content "C:\Program Files\ClamAV\freshclam.conf") -replace '^Example$','' | Set-Content "C:\Program Files\ClamAV\freshclam.conf"

& 'C:\Program Files\ClamAV\clamd.exe' --install
& 'C:\Program Files\ClamAV\freshclam.exe'

net start clamd