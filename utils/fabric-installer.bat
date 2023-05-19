@echo off

set filepath=".\datadir\launcher_profiles.json"

if not exist "%filepath%" (
    echo [31mThe file %filepath% does not exist.[0m
    echo [33mThe launcher is starting. Please log-in, then close it to continue.[0m

    start /W "" "%~dp0javafolder\bin\javaw.exe" -jar "%~dp0launchername" --workdir "%~dp0datadir"
    echo.
)

set pwsFabricUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/utils/fabric-downloader.ps1

for %%F in ("%pwsFabricUrl%") do set "pwsFabricName=%%~nF"
set pwsFabricName=%pwsFabricName%.ps1

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%pwsFabricUrl%', '.\%pwsFabricName%')" >NUL 2>&1

powershell -ExecutionPolicy Bypass -File "%pwsFabricName%" >NUL 2>&1

".\javafolder\bin\java.exe" -jar ".\fabric.jar" client -dir ".\datadir"

if exist ".\%pwsFabricName%" (
    del /F ".\%pwsFabricName%" >NUL 2>&1
)

if exist ".\fabric.jar" (
    del /F ".\fabric.jar" >NUL 2>&1
)

pause

if exist ".\%~nx0" (
    del /F ".\%~nx0" >NUL 2>&1
)