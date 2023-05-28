@echo off

set guiUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/gui.ps1
set helperModuleUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/helper.psm1

for %%F in ("%guiUrl%") do set "guiName=%%~nF"
set guiName=%guiName%.ps1

for %%F in ("%helperModuleUrl%") do set "helperModuleName=%%~nF"
set helperModuleName=%helperModuleName%.psm1

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%guiUrl%', '.\%guiName%')" >NUL 2>&1
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%helperModuleUrl%', '.\%helperModuleName%')" >NUL 2>&1
powershell -ExecutionPolicy Bypass -File ".\%guiName%"

if exist ".\%guiName%" (
    del /F ".\%guiName%" >NUL 2>&1
)

if exist ".\%helperModuleName%" (
    del /F ".\%helperModuleName%" >NUL 2>&1
)