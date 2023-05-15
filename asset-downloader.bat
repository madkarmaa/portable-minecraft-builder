@echo off
setlocal

set "matchPattern=%~1"
set "apiUrl=%~2"

powershell -command "$response=Invoke-RestMethod -Uri '%apiUrl%';$asset=$response.assets|Where-Object {$_.browser_download_url -like '%matchPattern%'};if($asset){$downloadUrl=$asset.browser_download_url;$fileName=$asset.name;Invoke-WebRequest -Uri $downloadUrl -OutFile $fileName}else{exit 1}"

endlocal
