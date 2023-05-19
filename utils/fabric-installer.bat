@echo off

set pwsFabricUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/utils/fabric-downloader.ps1

for %%F in ("%pwsFabricUrl%") do set "pwsFabricName=%%~nF"
set pwsFabricName=%pwsFabricName%.ps1

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%pwsFabricUrl%', '.\%pwsFabricName%')" >NUL 2>&1

powershell -ExecutionPolicy Bypass -File "%pwsFabricName%" >NUL 2>&1

".\javafolder\bin\java.exe" -jar .\fabric.jar client -dir ".\datadir"

if exist ".\%pwsFabricName%" (
    del /F ".\%pwsFabricName%" >NUL 2>&1
)

if exist ".\fabric.jar" (
    del /F ".\fabric.jar" >NUL 2>&1
)