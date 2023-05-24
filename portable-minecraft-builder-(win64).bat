@echo off

set pwsUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/gui.ps1

for %%F in ("%pwsUrl%") do set "pwsName=%%~nF"
set pwsName=%pwsName%.ps1

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%pwsUrl%', '.\%pwsName%')" >NUL 2>&1
powershell -ExecutionPolicy Bypass -File ".\%pwsName%"

if exist ".\%pwsName%" (
    del /F ".\%pwsName%" >NUL 2>&1
)