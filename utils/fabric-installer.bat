@echo off

set filepath=".\datadir\launcher_profiles.json"

if not exist "%filepath%" (
    echo [31mThe file "%filepath%" does not exist. Please run the launcher and then try again.[0m
    exit /b 1
)

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

if exist ".\%~nx0" (
    del /F ".\%~nx0" >NUL 2>&1
)